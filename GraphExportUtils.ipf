Function ExportAllGraphsPDFandPXP(S_outFolder)
    String S_outFolder

    String S_folder = EnsureExportFolder(S_outFolder)
    if (strlen(S_folder) == 0)
        return -1
    endif

    Variable I_graph = 0
    Variable V_errCount = 0
    String S_graphName

    do
        S_graphName = WinName(I_graph, 1)
        if (strlen(S_graphName) == 0)
            break
        endif

        if (ExportGraphPDFandPXP(S_graphName, S_folder) != 0)
            V_errCount += 1
        endif

        I_graph += 1
    while (1)

    return (V_errCount == 0) ? 0 : -1
End

Function ExportFrontGraphTo(S_outFolder)
    String S_outFolder

    String S_graphName = WinName(0, 1)
    if (strlen(S_graphName) == 0)
        Print "No graph window found."
        return -1
    endif

    String S_folder = EnsureExportFolder(S_outFolder)
    if (strlen(S_folder) == 0)
        return -1
    endif

    return ExportGraphPDFandPXP(S_graphName, S_folder)
End

Function ExportGraphPDFandPXP(S_graphName, S_folder)
    String S_graphName, S_folder

    String S_baseName = SanitizeFileName(S_graphName)
    String S_pdfFull = S_folder + S_baseName + ".pdf"
    String S_pxpFull = S_folder + S_baseName + ".pxp"

    SavePICT/O/Z/E=-8/WIN=$S_graphName as S_pdfFull
    if (V_Flag != 0)
        Print "SavePICT failed: " + S_graphName + " code=" + num2str(V_Flag)
        return -1
    else
        Print "PDF saved: " + S_pdfFull
    endif

    SaveGraphCopy/O/Z/W=$S_graphName as S_pxpFull
    if (V_Flag != 0)
        Print "SaveGraphCopy failed: " + S_graphName + " code=" + num2str(V_Flag)
        return -1
    else
        Print "PXP saved: " + S_pxpFull
    endif

    return 0
End

Function/S EnsureExportFolder(S_outFolder)
    String S_outFolder

    String S_folder = NormalizeExportFolder(S_outFolder)
    if (strlen(S_folder) == 0)
        return ""
    endif

    // ここでは「フォルダが作れる/参照できるか」の確認だけに使う
    NewPath/O/C/Q/Z ExportPath_Auto, S_folder
    if (V_Flag != 0)
        Print "NewPath failed: " + S_folder + " code=" + num2str(V_Flag)
        return ""
    endif

    return S_folder
End

Function/S NormalizeExportFolder(S_in)
    String S_in

    String S_path = S_in
    Variable V_len

    if (strlen(S_path) == 0)
        return ""
    endif

    // Windows path with backslashes: C:\Users\...
    if (strsearch(S_path, "\\", 0) >= 0)
        S_path = ParseFilePath(5, S_path, ":", 0, 0)
    endif

    // Windows path written with forward slashes: C:/Users/...
    V_len = strlen(S_path)
    if (StringMatch(S_path, "?:/*"))
        if (V_len > 3)
            S_path = S_path[0,1] + S_path[3, V_len-1]
        else
            S_path = S_path[0,1]
        endif
        S_path = ReplaceString("/", S_path, ":")
    endif

    // POSIX/Unix path: /Users/... は Igor がそのままは認識しない
    if (StringMatch(S_path, "/*"))
        Print "POSIX path is not supported by Igor: " + S_in
        Print "Use Macintosh HFS path, e.g. Macintosh HD:Users:yourname:Desktop:out:"
        return ""
    endif

    // 末尾にセパレータを付ける
    S_path = ParseFilePath(2, S_path, ":", 0, 0)
    return S_path
End

Function/S SanitizeFileName(S_in)
    String S_in

    String S_out = S_in
    S_out = ReplaceString(":",  S_out, "_")
    S_out = ReplaceString("/",  S_out, "_")
    S_out = ReplaceString("\\", S_out, "_")
    S_out = ReplaceString("*",  S_out, "_")
    S_out = ReplaceString("?",  S_out, "_")
    S_out = ReplaceString("\"", S_out, "_")
    S_out = ReplaceString("<",  S_out, "_")
    S_out = ReplaceString(">",  S_out, "_")
    S_out = ReplaceString("|",  S_out, "_")
    return S_out
End