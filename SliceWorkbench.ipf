#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3

// ============================================================
// SliceWorkbench.ipf
//
// Clean replacement core for 2D/3D/4D slicing and profile extraction.
//
// Main goals:
//  1) Robust 4D -> 3D extraction
//  2) Robust 3D -> 2D extraction
//  3) Correct center-plane extraction
//  4) Strip / band profile with finite width
//  5) Backward-compatible wrappers for old function names
//
// Notes:
//  - This file is intentionally core-only. A panel can be layered on top.
//  - Indices are clamped safely.
//  - Range extraction supports single-slice, slab mean, slab sum.
//
// Mode definition:
//    0 : mean
//    1 : sum
// ============================================================


// ------------------------------------------------------------
// Basic utilities
// ------------------------------------------------------------

Function SliceWB_ClampValue(v, vMin, vMax)
    Variable v, vMin, vMax

    if (v < vMin)
        return vMin
    endif
    if (v > vMax)
        return vMax
    endif
    return v
End

Function SliceWB_ClampIndex(W_src, dimNo, index)
    Wave W_src
    Variable dimNo, index

    Variable n = DimSize(W_src, dimNo)
    if (n <= 0)
        return 0
    endif

    index = round(index)
    if (index < 0)
        index = 0
    endif
    if (index > n-1)
        index = n-1
    endif
    return index
End

Function SliceWB_AxisToPoint(W_src, dimNo, pos)
    Wave W_src
    Variable dimNo, pos

    Variable delta = DimDelta(W_src, dimNo)
    if (delta == 0)
        return 0
    endif
    return (pos - DimOffset(W_src, dimNo)) / delta
End

Function SliceWB_PointToAxis(W_src, dimNo, pnt)
    Wave W_src
    Variable dimNo, pnt

    return DimOffset(W_src, dimNo) + DimDelta(W_src, dimNo) * pnt
End

Function/S SliceWB_DefaultOutName(W_src, suffix)
    Wave W_src
    String suffix

    String S_name = CleanupName(NameOfWave(W_src) + suffix, 0)
    return S_name
End

Function SliceWB_Valid2D(W_src)
    Wave W_src

    if (DimSize(W_src, 0) <= 0)
        return 0
    endif
    if (DimSize(W_src, 1) <= 0)
        return 0
    endif
    return 1
End

Function SliceWB_Valid3D(W_src)
    Wave W_src

    if (!SliceWB_Valid2D(W_src))
        return 0
    endif
    if (DimSize(W_src, 2) <= 0)
        return 0
    endif
    return 1
End

Function SliceWB_Valid4D(W_src)
    Wave W_src

    if (!SliceWB_Valid3D(W_src))
        return 0
    endif
    if (DimSize(W_src, 3) <= 0)
        return 0
    endif
    return 1
End

Function SliceWB_Set2DScaleFrom3D(W_dest, W_src, fixedDim)
    Wave W_dest, W_src
    Variable fixedDim

    switch (fixedDim)
        case 0:
            SetScale/P x, DimOffset(W_src, 1), DimDelta(W_src, 1), WaveUnits(W_src, 1), W_dest
            SetScale/P y, DimOffset(W_src, 2), DimDelta(W_src, 2), WaveUnits(W_src, 2), W_dest
            break
        case 1:
            SetScale/P x, DimOffset(W_src, 0), DimDelta(W_src, 0), WaveUnits(W_src, 0), W_dest
            SetScale/P y, DimOffset(W_src, 2), DimDelta(W_src, 2), WaveUnits(W_src, 2), W_dest
            break
        case 2:
            SetScale/P x, DimOffset(W_src, 0), DimDelta(W_src, 0), WaveUnits(W_src, 0), W_dest
            SetScale/P y, DimOffset(W_src, 1), DimDelta(W_src, 1), WaveUnits(W_src, 1), W_dest
            break
        default:
            Print "SliceWB_Set2DScaleFrom3D: invalid fixedDim =", fixedDim
            break
    endswitch
End

Function SliceWB_Set3DScaleFrom4D(W_dest, W_src, fixedDim)
    Wave W_dest, W_src
    Variable fixedDim

    switch (fixedDim)
        case 0:
            SetScale/P x, DimOffset(W_src, 1), DimDelta(W_src, 1), WaveUnits(W_src, 1), W_dest
            SetScale/P y, DimOffset(W_src, 2), DimDelta(W_src, 2), WaveUnits(W_src, 2), W_dest
            SetScale/P z, DimOffset(W_src, 3), DimDelta(W_src, 3), WaveUnits(W_src, 3), W_dest
            break
        case 1:
            SetScale/P x, DimOffset(W_src, 0), DimDelta(W_src, 0), WaveUnits(W_src, 0), W_dest
            SetScale/P y, DimOffset(W_src, 2), DimDelta(W_src, 2), WaveUnits(W_src, 2), W_dest
            SetScale/P z, DimOffset(W_src, 3), DimDelta(W_src, 3), WaveUnits(W_src, 3), W_dest
            break
        case 2:
            SetScale/P x, DimOffset(W_src, 0), DimDelta(W_src, 0), WaveUnits(W_src, 0), W_dest
            SetScale/P y, DimOffset(W_src, 1), DimDelta(W_src, 1), WaveUnits(W_src, 1), W_dest
            SetScale/P z, DimOffset(W_src, 3), DimDelta(W_src, 3), WaveUnits(W_src, 3), W_dest
            break
        case 3:
            SetScale/P x, DimOffset(W_src, 0), DimDelta(W_src, 0), WaveUnits(W_src, 0), W_dest
            SetScale/P y, DimOffset(W_src, 1), DimDelta(W_src, 1), WaveUnits(W_src, 1), W_dest
            SetScale/P z, DimOffset(W_src, 2), DimDelta(W_src, 2), WaveUnits(W_src, 2), W_dest
            break
        default:
            Print "SliceWB_Set3DScaleFrom4D: invalid fixedDim =", fixedDim
            break
    endswitch
End


// ------------------------------------------------------------
// 4D -> 3D extraction
// ------------------------------------------------------------

Function/S SliceWB_Extract3DFrom4DRange(W_src, fixedDim, i0, i1, mode, outName)
    Wave W_src
    Variable fixedDim, i0, i1, mode
    String outName

    if (!SliceWB_Valid4D(W_src))
        Print "SliceWB_Extract3DFrom4DRange: source is not 4D"
        return ""
    endif

    if (strlen(outName) == 0)
        outName = SliceWB_DefaultOutName(W_src, "_3D")
    endif

    i0 = SliceWB_ClampIndex(W_src, fixedDim, i0)
    i1 = SliceWB_ClampIndex(W_src, fixedDim, i1)
    if (i1 < i0)
        Variable tmp = i0
        i0 = i1
        i1 = tmp
    endif

    Variable n0, n1, n2
    switch (fixedDim)
        case 0:
            n0 = DimSize(W_src, 1)
            n1 = DimSize(W_src, 2)
            n2 = DimSize(W_src, 3)
            break
        case 1:
            n0 = DimSize(W_src, 0)
            n1 = DimSize(W_src, 2)
            n2 = DimSize(W_src, 3)
            break
        case 2:
            n0 = DimSize(W_src, 0)
            n1 = DimSize(W_src, 1)
            n2 = DimSize(W_src, 3)
            break
        case 3:
            n0 = DimSize(W_src, 0)
            n1 = DimSize(W_src, 1)
            n2 = DimSize(W_src, 2)
            break
        default:
            Print "SliceWB_Extract3DFrom4DRange: invalid fixedDim =", fixedDim
            return ""
    endswitch

    Make/O/D/N=(n0, n1, n2) $outName
    Wave W_dest = $outName
    W_dest = 0

    Variable k, nAccum = 0
    for (k = i0; k <= i1; k += 1)
        switch (fixedDim)
            case 0:
                W_dest += W_src[k][p][q][r]
                break
            case 1:
                W_dest += W_src[p][k][q][r]
                break
            case 2:
                W_dest += W_src[p][q][k][r]
                break
            case 3:
                W_dest += W_src[p][q][r][k]
                break
        endswitch
        nAccum += 1
    endfor

    if (mode == 0 && nAccum > 0)
        W_dest /= nAccum
    endif

    SliceWB_Set3DScaleFrom4D(W_dest, W_src, fixedDim)
    return NameOfWave(W_dest)
End

Function/S SliceWB_Extract3DFrom4DCenter(W_src, fixedDim, centerIndex, halfWidth, mode, outName)
    Wave W_src
    Variable fixedDim, centerIndex, halfWidth, mode
    String outName

    centerIndex = SliceWB_ClampIndex(W_src, fixedDim, centerIndex)
    halfWidth = max(0, round(halfWidth))

    Variable i0 = centerIndex - halfWidth
    Variable i1 = centerIndex + halfWidth

    return SliceWB_Extract3DFrom4DRange(W_src, fixedDim, i0, i1, mode, outName)
End

Function/S Extract3Dfrom4D(ctrlName, W_src, F_FixedDim, V_FixedPoint)
    String ctrlName
    Wave W_src
    Variable F_FixedDim, V_FixedPoint

    return SliceWB_Extract3DFrom4DCenter(W_src, F_FixedDim, V_FixedPoint, 0, 0, "")
End


// ------------------------------------------------------------
// 3D -> 2D extraction
// ------------------------------------------------------------

Function/S SliceWB_Extract2DFrom3DRange(W_src, fixedDim, i0, i1, mode, outName)
    Wave W_src
    Variable fixedDim, i0, i1, mode
    String outName

    if (!SliceWB_Valid3D(W_src))
        Print "SliceWB_Extract2DFrom3DRange: source is not 3D"
        return ""
    endif

    if (strlen(outName) == 0)
        outName = SliceWB_DefaultOutName(W_src, "_2D")
    endif

    i0 = SliceWB_ClampIndex(W_src, fixedDim, i0)
    i1 = SliceWB_ClampIndex(W_src, fixedDim, i1)
    if (i1 < i0)
        Variable tmp = i0
        i0 = i1
        i1 = tmp
    endif

    Variable n0, n1
    switch (fixedDim)
        case 0:
            n0 = DimSize(W_src, 1)
            n1 = DimSize(W_src, 2)
            break
        case 1:
            n0 = DimSize(W_src, 0)
            n1 = DimSize(W_src, 2)
            break
        case 2:
            n0 = DimSize(W_src, 0)
            n1 = DimSize(W_src, 1)
            break
        default:
            Print "SliceWB_Extract2DFrom3DRange: invalid fixedDim =", fixedDim
            return ""
    endswitch

    Make/O/D/N=(n0, n1) $outName
    Wave W_dest = $outName
    W_dest = 0

    Variable k, nAccum = 0
    for (k = i0; k <= i1; k += 1)
        switch (fixedDim)
            case 0:
                W_dest += W_src[k][p][q]
                break
            case 1:
                W_dest += W_src[p][k][q]
                break
            case 2:
                W_dest += W_src[p][q][k]
                break
        endswitch
        nAccum += 1
    endfor

    if (mode == 0 && nAccum > 0)
        W_dest /= nAccum
    endif

    SliceWB_Set2DScaleFrom3D(W_dest, W_src, fixedDim)
    return NameOfWave(W_dest)
End

Function/S SliceWB_Extract2DFrom3DCenter(W_src, fixedDim, centerIndex, halfWidth, mode, outName)
    Wave W_src
    Variable fixedDim, centerIndex, halfWidth, mode
    String outName

    centerIndex = SliceWB_ClampIndex(W_src, fixedDim, centerIndex)
    halfWidth = max(0, round(halfWidth))

    Variable i0 = centerIndex - halfWidth
    Variable i1 = centerIndex + halfWidth

    return SliceWB_Extract2DFrom3DRange(W_src, fixedDim, i0, i1, mode, outName)
End

Function/S Extract2Dfrom3D(ctrlName, W_src, F_FixedDim, V_FixedPoint)
    String ctrlName
    Wave W_src
    Variable F_FixedDim, V_FixedPoint

    return SliceWB_Extract2DFrom3DCenter(W_src, F_FixedDim, V_FixedPoint, 0, 0, "")
End


// ------------------------------------------------------------
// Compatibility wrappers for old 3D helpers
// ------------------------------------------------------------

Function/S Conv_3DSlice(S_src3Dwave, S_dest2Dwave, V_i_plane, F_plane)
    String S_src3Dwave, S_dest2Dwave
    Variable V_i_plane, F_plane

    Wave W_src = $S_src3Dwave

    // old convention:
    //   F_plane = 0 : XY plane -> fix Z -> fixedDim = 2
    //   F_plane = 1 : XZ plane -> fix Y -> fixedDim = 1
    //   F_plane = 2 : YZ plane -> fix X -> fixedDim = 0
    Variable fixedDim
    fixedDim = str2num(StringFromList(F_plane, "2;1;0"))

    return SliceWB_Extract2DFrom3DCenter(W_src, fixedDim, V_i_plane, 0, 0, S_dest2Dwave)
End

Function/S GetCenterPlane(S_3DWname_src, S_2DWname_dist, F_plane)
    String S_3DWname_src, S_2DWname_dist
    Variable F_plane

    Wave W_src = $S_3DWname_src
    Variable fixedDim = str2num(StringFromList(F_plane, "2;1;0"))
    Variable n = DimSize(W_src, fixedDim)

    if (n <= 0)
        Print "GetCenterPlane: invalid source wave or fixedDim"
        return ""
    endif

    if (mod(n, 2) == 1)
        Variable c = floor((n - 1) / 2)
        return SliceWB_Extract2DFrom3DCenter(W_src, fixedDim, c, 0, 0, S_2DWname_dist)
    else
        Variable c0 = n/2 - 1
        Variable c1 = n/2
        return SliceWB_Extract2DFrom3DRange(W_src, fixedDim, c0, c1, 0, S_2DWname_dist)
    endif
End

Function/S SliceWB_GetCenterSlabPlane(S_3DWname_src, S_2DWname_dist, F_plane, halfWidth, mode)
    String S_3DWname_src, S_2DWname_dist
    Variable F_plane, halfWidth, mode

    Wave W_src = $S_3DWname_src
    Variable fixedDim = str2num(StringFromList(F_plane, "2;1;0"))
    Variable n = DimSize(W_src, fixedDim)
    Variable c = floor((n - 1) / 2)

    return SliceWB_Extract2DFrom3DCenter(W_src, fixedDim, c, halfWidth, mode, S_2DWname_dist)
End


// ------------------------------------------------------------
// 2D strip profiles (axis-aligned)
// ------------------------------------------------------------

Function/S SliceWB_StripProfile2D(W_src, profileDim, centerIndex, halfWidth, mode, outName)
    Wave W_src
    Variable profileDim, centerIndex, halfWidth, mode
    String outName

    if (!SliceWB_Valid2D(W_src))
        Print "SliceWB_StripProfile2D: source is not 2D"
        return ""
    endif

    if (strlen(outName) == 0)
        if (profileDim == 0)
            outName = SliceWB_DefaultOutName(W_src, "_StripX")
        else
            outName = SliceWB_DefaultOutName(W_src, "_StripY")
        endif
    endif

    halfWidth = max(0, round(halfWidth))

    Variable nProfile, avgDim
    if (profileDim == 0)
        nProfile = DimSize(W_src, 0)
        avgDim = 1
    else
        nProfile = DimSize(W_src, 1)
        avgDim = 0
    endif

    centerIndex = SliceWB_ClampIndex(W_src, avgDim, centerIndex)
    Variable i0 = SliceWB_ClampIndex(W_src, avgDim, centerIndex - halfWidth)
    Variable i1 = SliceWB_ClampIndex(W_src, avgDim, centerIndex + halfWidth)

    Make/O/D/N=(nProfile) $outName
    Wave W_out = $outName
    W_out = 0

    Variable k, nAccum = 0
    if (profileDim == 0)
        for (k = i0; k <= i1; k += 1)
            W_out += W_src[p][k]
            nAccum += 1
        endfor
        SetScale/P x, DimOffset(W_src, 0), DimDelta(W_src, 0), WaveUnits(W_src, 0), W_out
    else
        for (k = i0; k <= i1; k += 1)
            W_out += W_src[k][p]
            nAccum += 1
        endfor
        SetScale/P x, DimOffset(W_src, 1), DimDelta(W_src, 1), WaveUnits(W_src, 1), W_out
    endif

    if (mode == 0 && nAccum > 0)
        W_out /= nAccum
    endif

    return NameOfWave(W_out)
End


// ------------------------------------------------------------
// Arbitrary-width line profile on 2D image
// ------------------------------------------------------------

Function SliceWB_Bilinear2D(W_src, xP, yP)
    Wave W_src
    Variable xP, yP

    Variable nx = DimSize(W_src, 0)
    Variable ny = DimSize(W_src, 1)

    if (nx < 1 || ny < 1)
        return NaN
    endif

    if (xP < 0 || xP > nx-1 || yP < 0 || yP > ny-1)
        return NaN
    endif

    Variable x0 = floor(xP)
    Variable y0 = floor(yP)
    Variable x1 = min(x0 + 1, nx - 1)
    Variable y1 = min(y0 + 1, ny - 1)

    Variable tx = xP - x0
    Variable ty = yP - y0

    Variable v00 = W_src[x0][y0]
    Variable v10 = W_src[x1][y0]
    Variable v01 = W_src[x0][y1]
    Variable v11 = W_src[x1][y1]

    return (1 - tx) * (1 - ty) * v00 + tx * (1 - ty) * v10 + (1 - tx) * ty * v01 + tx * ty * v11
End

Function/S SliceWB_WideLineProfile2DByPoint(W_src, xP0, yP0, xP1, yP1, widthPx, nSamples, mode, outName)
    Wave W_src
    Variable xP0, yP0, xP1, yP1, widthPx, nSamples, mode
    String outName

    if (!SliceWB_Valid2D(W_src))
        Print "SliceWB_WideLineProfile2DByPoint: source is not 2D"
        return ""
    endif

    if (strlen(outName) == 0)
        outName = SliceWB_DefaultOutName(W_src, "_BandProfile")
    endif

    Variable dx = xP1 - xP0
    Variable dy = yP1 - yP0
    Variable L = sqrt(dx*dx + dy*dy)
    if (L <= 0)
        Print "SliceWB_WideLineProfile2DByPoint: zero length line"
        return ""
    endif

    if (nSamples <= 1)
        nSamples = max(2, round(L) + 1)
    else
        nSamples = round(nSamples)
    endif

    widthPx = max(0, widthPx)

    Make/O/D/N=(nSamples) $outName
    Wave W_out = $outName
    W_out = NaN

    Variable tx = dx / L
    Variable ty = dy / L
    Variable nx = -ty
    Variable ny = tx

    Variable i, j
    Variable xc, yc, xs, ys
    Variable value, sumVal, maxVal, cnt
    Variable nAcross

    if (widthPx <= 0)
        nAcross = 1
    else
        nAcross = max(1, round(widthPx) + 1)
    endif

    for (i = 0; i < nSamples; i += 1)
        Variable frac
        if (nSamples == 1)
            frac = 0
        else
            frac = i / (nSamples - 1)
        endif

        xc = xP0 + frac * dx
        yc = yP0 + frac * dy

        sumVal = 0
        maxVal = -1e300
        cnt = 0

        if (nAcross == 1)
            value = SliceWB_Bilinear2D(W_src, xc, yc)
            if (numtype(value) == 0)
                sumVal = value
                maxVal = value
                cnt = 1
            endif
        else
            Variable offsetMin = -0.5 * widthPx
            Variable offsetMax =  0.5 * widthPx
            for (j = 0; j < nAcross; j += 1)
                Variable fracAcross
                if (nAcross == 1)
                    fracAcross = 0
                else
                    fracAcross = j / (nAcross - 1)
                endif

                Variable off = offsetMin + fracAcross * (offsetMax - offsetMin)
                xs = xc + off * nx
                ys = yc + off * ny

                value = SliceWB_Bilinear2D(W_src, xs, ys)
                if (numtype(value) == 0)
                    sumVal += value
                    if (value > maxVal)
                        maxVal = value
                    endif
                    cnt += 1
                endif
            endfor
        endif

        if (cnt > 0)
            switch (mode)
                case 1:
                    W_out[i] = sumVal
                    break
                case 2:
                    W_out[i] = maxVal
                    break
                default:
                    W_out[i] = sumVal / cnt
                    break
            endswitch
        endif
    endfor

    String S_unitX = WaveUnits(W_src, 0)
    String S_unitY = WaveUnits(W_src, 1)
    String S_axisUnit = ""
    if (StringMatch(S_unitX, S_unitY))
        S_axisUnit = S_unitX
    endif

    Variable ax0 = SliceWB_PointToAxis(W_src, 0, xP0)
    Variable ay0 = SliceWB_PointToAxis(W_src, 1, yP0)
    Variable ax1 = SliceWB_PointToAxis(W_src, 0, xP1)
    Variable ay1 = SliceWB_PointToAxis(W_src, 1, yP1)

    Variable dPhys = sqrt((ax1 - ax0)^2 + (ay1 - ay0)^2)
    Variable dStep
    if (nSamples <= 1)
        dStep = 0
    else
        dStep = dPhys / (nSamples - 1)
    endif
    SetScale/P x, 0, dStep, S_axisUnit, W_out

    return NameOfWave(W_out)
End

Function/S SliceWB_WideLineProfile2DByAxis(W_src, x0, y0, x1, y1, widthPhys, nSamples, mode, outName)
    Wave W_src
    Variable x0, y0, x1, y1, widthPhys, nSamples, mode
    String outName

    Variable xP0 = SliceWB_AxisToPoint(W_src, 0, x0)
    Variable yP0 = SliceWB_AxisToPoint(W_src, 1, y0)
    Variable xP1 = SliceWB_AxisToPoint(W_src, 0, x1)
    Variable yP1 = SliceWB_AxisToPoint(W_src, 1, y1)

    Variable dxScale = abs(DimDelta(W_src, 0))
    Variable dyScale = abs(DimDelta(W_src, 1))
    Variable meanScale = 0.5 * (dxScale + dyScale)
    Variable widthPx

    if (meanScale > 0)
        widthPx = widthPhys / meanScale
    else
        widthPx = 0
    endif

    return SliceWB_WideLineProfile2DByPoint(W_src, xP0, yP0, xP1, yP1, widthPx, nSamples, mode, outName)
End


// ------------------------------------------------------------
// Convenience helpers for center profiles with width
// ------------------------------------------------------------

Function/S SliceWB_GetCenterProfiles2D(W_src, baseName, halfWidth)
    Wave W_src
    String baseName
    Variable halfWidth

    if (strlen(baseName) == 0)
        baseName = CleanupName(NameOfWave(W_src) + "_Center", 0)
    endif

    Variable cx = floor((DimSize(W_src, 0) - 1) / 2)
    Variable cy = floor((DimSize(W_src, 1) - 1) / 2)

    String Sx = baseName + "_x"
    String Sy = baseName + "_y"

    SliceWB_StripProfile2D(W_src, 0, cy, halfWidth, 0, Sx)
    SliceWB_StripProfile2D(W_src, 1, cx, halfWidth, 0, Sy)

    return baseName
End


// ------------------------------------------------------------
// Minimal example macros
// ------------------------------------------------------------

Macro SliceWB_Example_3DTo2D_CenterMean()
    // Edit these two lines before execution.
    String S_src = "W_3D"
    String S_dst = "W_3D_XY_center"

    // F_plane: 0=XY, 1=XZ, 2=YZ
    GetCenterPlane(S_src, S_dst, 0)
End

Macro SliceWB_Example_3DTo2D_CenterSlabMean()
    // Edit these two lines before execution.
    String S_src = "W_3D"
    String S_dst = "W_3D_XY_centerSlab"

    // F_plane: 0=XY, 1=XZ, 2=YZ
    // halfWidth = 2 means 5-plane slab when possible.
    SliceWB_GetCenterSlabPlane(S_src, S_dst, 0, 2, 0)
End

Macro SliceWB_Example_WideBandProfile()
    // Edit these two lines before execution.
    Wave M_src = M_ImagePlane
    String S_out = "W_BandProfile"

    // Here the line is specified in point coordinates.
    // widthPx = 7 means a finite-width strip, not a single-pixel line.
    SliceWB_WideLineProfile2DByPoint(M_src, 20, 20, 180, 80, 7, 300, 0, S_out)
End

