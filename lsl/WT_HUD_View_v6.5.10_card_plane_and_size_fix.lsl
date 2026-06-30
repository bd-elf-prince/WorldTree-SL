/* WT_HUD_View v6.5.10-card-plane-and-size-fix
 * Based on v6.5.7.
 * Fixes the v6.5.8/v6.5.9 card drop and size drift.
 * - Requested raw card Z: -0.52972
 * - Preserves original script's +1.0 plane correction when raw Z is below -0.10
 * - Visible plane becomes 0.47028, so cards move slightly down instead of falling to floor
 * - Normalizes card face Y/Z to 0.12407
 * - Keeps card X thickness from current prim size
 * - Uses full copy script for direct raw copy
 */

integer TO_CORE = 1001;
integer TO_VIEW = 3001;

string TEX_ANGEL = "a5bc223c-88b9-e8fc-a7a6-95a6b1f6e2c3";
string TEX_DEMON = "661c9988-7f2f-4027-186a-4a0cbf5b8c33";
string TEX_BACK  = "70b78c17-bff6-8706-261f-655d39e4c8b3";

integer cLv = 1;
integer exp = 0;
integer gold = 0;
integer dia = 0;
integer wood = 0;
integer bag = 50;
integer weapon = 0;
integer tens = 0;
string tier = "basic";
integer statStr = 0;
integer statDex = 0;
integer statInt = 0;
integer statVit = 0;
integer statPtr = 0;

integer panel;
integer yesBtn;
integer noBtn;
integer infoText;
vector panelPos;
vector yesPos;
vector noPos;

list cards = [
    0, <0,0,0>, 0, <0,0,0>, 0, <0,0,0>,
    0, <0,0,0>, 0, <0,0,0>, 0, <0,0,0>
];
list baseSizes = [
    <0,0,0>, <0,0,0>, <0,0,0>,
    <0,0,0>, <0,0,0>, <0,0,0>
];

vector HIDE = <0,0,5>;
vector POP = <-0.120,0,0.045>;
float cardPlane;
float RAW_CARD_Z = -0.52972;
float CARD_FACE = 0.12407;

integer stateNo;
integer hasData;

integer pressedCard;
integer pressedLink;
integer pressInside;
integer pressCancelled;
integer pressStep;

integer resolving;
integer flipStep;
integer resultSuccess;
integer selectedLink;
vector selectedSize;
vector selectedPos;

string locale = "{}";
string localeBuf = "";
integer localeReceiving;
integer localeCount;
integer localeSeen;

string rep(string s, string a, string b) {
    return llDumpList2String(llParseStringKeepNulls(s,[a],[]),b);
}

string clean(string s) {
    s = llToLower(llStringTrim(s,STRING_TRIM));
    s = rep(s," ","");
    s = rep(s,"_","");
    s = rep(s,"-","");
    s = rep(s,".","");
    return s;
}

integer has(string s, string p) {
    return llSubStringIndex(s,p) != -1;
}

integer cardNo(string raw) {
    string n = clean(raw);
    if (!has(n,"card")) return 0;
    if (has(n,"1")) return 1;
    if (has(n,"2")) return 2;
    if (has(n,"3")) return 3;
    if (has(n,"4")) return 4;
    if (has(n,"5")) return 5;
    if (has(n,"6")) return 6;
    return 0;
}

integer linkOf(integer n) {
    return llList2Integer(cards,(n-1)*2);
}

vector posOf(integer n) {
    return llList2Vector(cards,((n-1)*2)+1);
}

vector sizeOf(integer n) {
    return llList2Vector(baseSizes,n-1);
}

integer visibleCount() {
    integer n = weapon - 3;
    if (n < 2) n = 2;
    if (n > 6) n = 6;
    return n;
}

vector unhide(vector p) {
    integer i;
    while (p.z >= 4.0 && i < 10) {
        p -= HIDE;
        ++i;
    }
    return p;
}

vector normalizeCardSize(vector z) {
    if (z.x <= 0.0) z.x = 0.01;
    z.y = CARD_FACE;
    z.z = CARD_FACE;
    return z;
}

recoverPlane() {
    cardPlane = RAW_CARD_Z;

    // Important: v6.5.7 raised negative card planes by +1.0.
    // Without this, -0.52972 is interpreted as floor/below-HUD and cards drop.
    if (cardPlane < -0.10) cardPlane += 1.0;

    integer n;
    for (n=1; n<=6; ++n) {
        integer idx = (n-1)*2;
        integer l = llList2Integer(cards,idx);
        if (l > 0) {
            vector p = llList2Vector(cards,idx+1);
            p.z = cardPlane;
            cards = llListReplaceList(cards,[l,p],idx,idx+1);
        }
    }
}

vector centered(integer index, integer count) {
    vector first = posOf(1);
    vector last = posOf(6);
    vector step = (last-first)/5.0;
    vector center = (first+last)/2.0;
    float off = (float)index - (((float)count-1.0)*0.5);
    return center + (step*off);
}

string msg(string keyName) {
    string v = llJsonGetValue(locale,[keyName]);
    if (v == JSON_INVALID || v == "") return "["+keyName+"]";
    return rep(v,"\\n","\n");
}

requestState() {
    llMessageLinked(LINK_THIS,TO_CORE,"LOCALE_REQUEST|VIEW",NULL_KEY);
    llMessageLinked(LINK_THIS,TO_CORE,"DATA_REQUEST",NULL_KEY);
}

renderInfo() {
    integer atk = 10 + (weapon*5);
    string s =
        msg("INFO_LV")+(string)cLv+" ("+msg("INFO_EXP")+": "+
        (string)exp+"/"+(string)(cLv*100)+")\n"+
        msg("INFO_GOLD")+": "+(string)gold+" | "+
        msg("INFO_DIA")+": "+(string)dia+" | "+
        msg("INFO_WOOD")+": "+(string)wood+"/"+(string)bag+"\n"+
        msg("INFO_ATK")+": "+(string)atk+" (+"+(string)weapon+") [10+: "+
        (string)tens+"]\n"+msg("INFO_STAT")+"["+msg("INFO_POINT")+":"+
        (string)statPtr+"] - STR:"+(string)statStr+" DEX:"+(string)statDex+
        " INT:"+(string)statInt+" VIT:"+(string)statVit+"\n"+
        msg("INFO_TIER")+": ["+tier+"]";

    if (infoText) llSetLinkPrimitiveParamsFast(infoText,[PRIM_TEXT,s,<1,1,1>,1.0]);
    else llSetText(s,<1,1,1>,1.0);
}

setBrightness(integer link, float b) {
    if (link > 0) llSetLinkPrimitiveParamsFast(
        link,[PRIM_COLOR,ALL_SIDES,<b,b,b>,1.0,PRIM_GLOW,ALL_SIDES,0.0]
    );
}

setBack(integer link) {
    if (link > 0) llSetLinkPrimitiveParamsFast(
        link,[PRIM_TEXTURE,ALL_SIDES,TEX_BACK,<1,1,0>,<0,0,0>,0.0]
    );
}

restoreCards() {
    integer n;
    for (n=1; n<=6; ++n) {
        integer l = linkOf(n);
        vector z = sizeOf(n);
        if (l > 0) {
            llSetLinkPrimitiveParamsFast(l,[
                PRIM_TEXTURE,ALL_SIDES,TEX_BACK,<1,1,0>,<0,0,0>,0.0,
                PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0,
                PRIM_GLOW,ALL_SIDES,0.0,
                PRIM_SIZE,z
            ]);
        }
    }
}

clearPress() {
    if (pressedLink > 0) setBrightness(pressedLink,1.0);
    pressedCard = 0;
    pressedLink = 0;
    pressInside = FALSE;
    pressCancelled = FALSE;
    pressStep = 0;
}

restoreSelected() {
    if (selectedLink <= 0) return;
    llSetLinkPrimitiveParamsFast(selectedLink,[
        PRIM_TEXTURE,ALL_SIDES,TEX_BACK,<1,1,0>,<0,0,0>,0.0,
        PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0,
        PRIM_GLOW,ALL_SIDES,0.0,
        PRIM_SIZE,selectedSize,
        PRIM_POS_LOCAL,selectedPos
    ]);
}

resetInteraction() {
    llSetTimerEvent(0.0);
    clearPress();
    restoreSelected();
    restoreCards();
    resolving = FALSE;
    flipStep = 0;
    resultSuccess = FALSE;
    selectedLink = 0;
    selectedSize = <0,0,0>;
    selectedPos = <0,0,0>;
}

integer touchInside(integer i) {
    if (pressedLink <= 0) return FALSE;
    if (llDetectedLinkNumber(i) != pressedLink) return FALSE;
    vector uv = llDetectedTouchUV(i);
    if (uv == TOUCH_INVALID_TEXCOORD) return FALSE;
    return uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0;
}

setUI(integer s) {
    if (s != 3) resetInteraction();
    else if (!resolving) {
        clearPress();
        restoreCards();
    }

    stateNo = s;
    list p = [];
    string text = "";
    string pad = "\n\n\n\n";
    vector pp = panelPos+HIDE;
    vector yp = yesPos+HIDE;
    vector np = noPos+HIDE;

    if (s == 1) {
        text = pad+msg("ENCH_GREET");
        pp=panelPos; yp=yesPos; np=noPos;
    }
    else if (s == 2) {
        string rate = "100%";
        if (weapon == 5) rate="50%";
        else if (weapon == 6) rate="40%";
        else if (weapon == 7) rate="30%";
        else if (weapon == 8) rate="20%";
        else if (weapon >= 9) rate="10%";
        text = msg("ENCH_INFO");
        text = rep(text,"{CUR}",(string)weapon);
        text = rep(text,"{NXT}",(string)(weapon+1));
        text = rep(text,"{RATE}",rate);
        text = pad+text;
        pp=panelPos; yp=yesPos; np=noPos;
    }
    else if (s == 3) {
        text = pad+msg("ENCH_PICK");
        pp=panelPos;
    }

    if (panel) p += [PRIM_LINK_TARGET,panel,PRIM_POS_LOCAL,pp,PRIM_TEXT,text,<0,0,0>,1.0];
    if (yesBtn) p += [PRIM_LINK_TARGET,yesBtn,PRIM_POS_LOCAL,yp];
    if (noBtn) p += [PRIM_LINK_TARGET,noBtn,PRIM_POS_LOCAL,np];

    integer count;
    if (s == 3) count = visibleCount();

    integer i;
    for (i=0; i<6; ++i) {
        integer n = i+1;
        integer l = linkOf(n);
        if (l > 0) {
            vector target = posOf(n)+HIDE;
            if (s == 3 && i < count) target = centered(i,count);
            p += [
                PRIM_LINK_TARGET,l,
                PRIM_POS_LOCAL,target,
                PRIM_SIZE,sizeOf(n),
                PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0,
                PRIM_GLOW,ALL_SIDES,0.0
            ];
        }
    }

    if (llGetListLength(p)) llSetLinkPrimitiveParamsFast(0,p);
}

integer chance() {
    if (weapon == 5) return 50;
    if (weapon == 6) return 40;
    if (weapon == 7) return 30;
    if (weapon == 8) return 20;
    if (weapon >= 9) return 10;
    return 100;
}

float ease(float t) {
    return t*t*(3.0-(2.0*t));
}

transform(float width, float scale, float lift) {
    vector z = selectedSize;
    z.y *= width*scale;
    z.z *= scale;
    if (z.y < 0.01) z.y = 0.01;
    llSetLinkPrimitiveParamsFast(selectedLink,[
        PRIM_SIZE,z,
        PRIM_POS_LOCAL,selectedPos+(POP*lift),
        PRIM_GLOW,ALL_SIDES,0.0
    ]);
}

finishResult() {
    integer ok = resultSuccess;
    restoreSelected();
    restoreCards();
    llSetTimerEvent(0.0);
    resolving = FALSE;
    flipStep = 0;

    if (ok) {
        string s = rep(msg("ENCH_SUC"),"{LV}",(string)(weapon+1));
        llOwnerSay(s);
        llMessageLinked(LINK_THIS,TO_CORE,"ENCHANT_SUCCESS",NULL_KEY);
    }
    else llOwnerSay(msg("ENCH_FAIL"));

    setUI(0);
}

startResolve(integer n) {
    if (resolving || stateNo != 3) return;
    integer l = linkOf(n);
    if (l <= 0) return;

    selectedLink = l;
    selectedSize = sizeOf(n);
    selectedPos = centered(n-1,visibleCount());
    resultSuccess = ((integer)llFrand(100.0)+1) <= chance();
    flipStep = 0;
    resolving = TRUE;
    setBrightness(selectedLink,1.0);
    llSetTimerEvent(0.055);
}

advancePress() {
    if (pressedLink <= 0 || resolving) return;
    float b;
    if (pressStep <= 10) b = 1.0 - ((float)pressStep*0.05);
    else b = 0.5 + ((float)(pressStep-10)*0.05);
    setBrightness(pressedLink,b);
    ++pressStep;
    if (pressStep > 20) pressStep = 0;
}

advanceFlip() {
    integer closeFrames = 6;
    integer openFrames = 7;

    if (flipStep < closeFrames) {
        float t = (float)(flipStep+1)/(float)closeFrames;
        float e = ease(t);
        transform(1.0-(0.96*e),1.0+(0.36*e),e);
        ++flipStep;
        return;
    }

    if (flipStep == closeFrames) {
        string tex = TEX_DEMON;
        if (resultSuccess) tex = TEX_ANGEL;
        llSetLinkPrimitiveParamsFast(selectedLink,[
            PRIM_TEXTURE,ALL_SIDES,tex,<1,1,0>,<0,0,0>,0.0,
            PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0
        ]);
        ++flipStep;
        return;
    }

    integer openIndex = flipStep-closeFrames;
    if (openIndex <= openFrames) {
        float t2 = (float)openIndex/(float)openFrames;
        float e2 = ease(t2);
        transform(0.04+(0.96*e2),1.36+(0.08*e2),1.0);
        ++flipStep;
        return;
    }

    if (flipStep == closeFrames+openFrames+1) {
        transform(1.0,1.40,1.0);
        ++flipStep;
        llSetTimerEvent(0.08);
        return;
    }

    if (flipStep == closeFrames+openFrames+2) {
        transform(1.0,1.36,1.0);
        ++flipStep;
        llSetTimerEvent(0.50);
        return;
    }

    finishResult();
}

initUI() {
    integer max = llGetNumberOfPrims();
    integer i;
    for (i=1; i<=max; ++i) {
        string raw = llGetLinkName(i);
        string n = clean(raw);
        vector p = unhide(llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_POS_LOCAL]),0));
        vector z = llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_SIZE]),0);

        if (!panel && has(n,"enchantpanel")) { panel=i; panelPos=p; }
        else if (!yesBtn && (has(n,"btnyes")||has(n,"buttonyes")||has(n,"yesbutton"))) { yesBtn=i; yesPos=p; }
        else if (!noBtn && (has(n,"btnno")||has(n,"buttonno")||has(n,"nobutton"))) { noBtn=i; noPos=p; }
        else if (!infoText && has(n,"infotext")) infoText=i;

        integer c = cardNo(raw);
        if (c >= 1 && c <= 6) {
            integer idx = (c-1)*2;
            if (llList2Integer(cards,idx) == 0) {
                z = normalizeCardSize(z);
                cards = llListReplaceList(cards,[i,p],idx,idx+1);
                baseSizes = llListReplaceList(baseSizes,[z],c-1,c-1);
            }
        }
    }

    recoverPlane();
    restoreCards();
    llOwnerSay("VIEW v6.5.10 ready. rawZ="+(string)RAW_CARD_Z+" visibleZ="+(string)cardPlane+" face="+(string)CARD_FACE+" memory="+(string)llGetFreeMemory());
}

default {
    state_entry() {
        initUI();
        setUI(0);
        requestState();
    }

    on_rez(integer p) { llResetScript(); }

    changed(integer c) {
        if (c & CHANGED_LINK) llResetScript();
    }

    link_message(integer sender, integer target, string m, key id) {
        if (target != TO_VIEW) return;

        if (llGetSubString(m,0,12) == "LOCALE_BEGIN|") {
            list a = llParseString2List(m,["|"],[]);
            localeBuf = "";
            localeReceiving = TRUE;
            localeCount = (integer)llList2String(a,1);
            localeSeen = 0;
            return;
        }

        if (llGetSubString(m,0,12) == "LOCALE_CHUNK|") {
            if (!localeReceiving) return;
            list a = llParseStringKeepNulls(m,["|"],[]);
            integer idx = (integer)llList2String(a,1);
            if (idx != localeSeen) {
                localeReceiving = FALSE;
                localeBuf = "";
                return;
            }
            string prefix = "LOCALE_CHUNK|"+(string)idx+"|";
            localeBuf += llGetSubString(m,llStringLength(prefix),-1);
            ++localeSeen;
            return;
        }

        if (llGetSubString(m,0,10) == "LOCALE_END|") {
            integer expected = (integer)llList2String(llParseString2List(m,["|"],[]),1);
            localeReceiving = FALSE;
            if (
                expected == localeCount &&
                localeSeen == expected &&
                llJsonValueType(localeBuf,[]) == JSON_OBJECT
            ) {
                locale = localeBuf;
                if (hasData) renderInfo();
                if (stateNo > 0) setUI(stateNo);
            }
            localeBuf = "";
            return;
        }

        if (m == "OPEN_ENCHANT_UI") {
            setUI(1);
            return;
        }

        list a = llParseStringKeepNulls(m,["|"],[]);
        if (llGetListLength(a) < 14) return;
        cLv=(integer)llList2String(a,0);
        exp=(integer)llList2String(a,1);
        gold=(integer)llList2String(a,2);
        dia=(integer)llList2String(a,3);
        wood=(integer)llList2String(a,4);
        bag=(integer)llList2String(a,5);
        weapon=(integer)llList2String(a,6);
        tens=(integer)llList2String(a,7);
        tier=llList2String(a,8);
        statStr=(integer)llList2String(a,9);
        statDex=(integer)llList2String(a,10);
        statInt=(integer)llList2String(a,11);
        statVit=(integer)llList2String(a,12);
        statPtr=(integer)llList2String(a,13);
        hasData=TRUE;
        renderInfo();
    }

    touch_start(integer count) {
        integer l = llDetectedLinkNumber(0);
        string n = clean(llGetLinkName(l));
        integer c = cardNo(n);
        integer isYes = has(n,"btnyes")||has(n,"buttonyes")||has(n,"yesbutton");
        integer isNo = has(n,"btnno")||has(n,"buttonno")||has(n,"nobutton");

        if (stateNo == 1) {
            if (isYes) setUI(2);
            else if (isNo) setUI(0);
            return;
        }

        if (stateNo == 2) {
            if (isYes) {
                if (weapon >= 10 && tens < 10) {
                    llOwnerSay(msg("ERR_LIMIT_10"));
                    setUI(0);
                }
                else if (gold < 5000) {
                    llOwnerSay(msg("ERR_NO_GOLD"));
                    setUI(0);
                }
                else {
                    llMessageLinked(LINK_THIS,TO_CORE,"ENCHANT_COST",NULL_KEY);
                    if (weapon < 5) {
                        resultSuccess = ((integer)llFrand(100.0)+1) <= chance();
                        finishResult();
                    }
                    else setUI(3);
                }
            }
            else if (isNo) setUI(0);
            return;
        }

        if (stateNo == 3 && !resolving && c >= 1 && c <= visibleCount()) {
            clearPress();
            pressedCard=c;
            pressedLink=l;
            pressInside=TRUE;
            pressStep=0;
            setBrightness(l,1.0);
            llSetTimerEvent(0.10);
        }
    }

    touch(integer count) {
        if (pressedCard <= 0 || resolving) return;
        integer inside = touchInside(0);
        if (!inside) pressCancelled=TRUE;
        if (pressCancelled) inside=FALSE;
        pressInside=inside;
    }

    touch_end(integer count) {
        if (pressedCard <= 0 || resolving) return;
        integer c=pressedCard;
        integer l=pressedLink;
        integer ok=!pressCancelled && pressInside && touchInside(0);
        setBrightness(l,1.0);
        clearPress();
        llSetTimerEvent(0.0);
        if (ok) startResolve(c);
    }

    timer() {
        if (resolving) advanceFlip();
        else if (pressedCard > 0) advancePress();
        else llSetTimerEvent(0.0);
    }
}

/* End WT_HUD_View v6.5.10-card-plane-and-size-fix */
