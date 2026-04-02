# SliceWorkbench.ipf

## 何を置き換えるか
- `Extract3Dfrom4D`
- `Extract2Dfrom3D`
- `Conv_3DSlice`
- `GetCenterPlane`

旧コードの問題だった
- 中心面の偶奇判定ミス
- off-by-one
- 範囲外 index
- 幅付きスキャンの未整備

を潰しつつ，以下を追加しています。

## 追加した機能
1. **slab 平均 / slab 和**
   - 3D→2D
   - 4D→3D
   - 単一 plane だけでなく，厚みを持った抽出が可能

2. **strip profile**
   - 2D画像から，X方向またはY方向に対して有限幅で平均化した 1D プロファイルを作成

3. **arbitrary wide line profile**
   - 2D画像上の任意2点を結ぶ線に対して，法線方向に幅を持たせた band profile を作成
   - 単なる 1 pixel line ではなく，有限幅の平均を取れる

## 主な関数
### 単一 plane / slab 抽出
- `SliceWB_Extract3DFrom4DRange(W_src, fixedDim, i0, i1, mode, outName)`
- `SliceWB_Extract3DFrom4DCenter(W_src, fixedDim, centerIndex, halfWidth, mode, outName)`
- `SliceWB_Extract2DFrom3DRange(W_src, fixedDim, i0, i1, mode, outName)`
- `SliceWB_Extract2DFrom3DCenter(W_src, fixedDim, centerIndex, halfWidth, mode, outName)`

`mode`
- `0` : mean
- `1` : sum

### 旧名互換
- `Extract3Dfrom4D(...)`
- `Extract2Dfrom3D(...)`
- `Conv_3DSlice(...)`
- `GetCenterPlane(...)`

### 幅付きプロファイル
- `SliceWB_StripProfile2D(W_src, profileDim, centerIndex, halfWidth, mode, outName)`
- `SliceWB_WideLineProfile2DByPoint(W_src, xP0, yP0, xP1, yP1, widthPx, nSamples, mode, outName)`
- `SliceWB_WideLineProfile2DByAxis(W_src, x0, y0, x1, y1, widthPhys, nSamples, mode, outName)`

## 使い方の例
### 3D wave の中心 XY 面
```igorpro
GetCenterPlane("W_3D", "W_xy_center", 0)
```

### 3D wave の中心 XY 面を 5 枚平均
```igorpro
SliceWB_GetCenterSlabPlane("W_3D", "W_xy_center5", 0, 2, 0)
```

### 2D image の中央 Y 帯を幅 7 point で平均し，X プロファイルを作る
```igorpro
Wave M_src = M_ImagePlane
SliceWB_StripProfile2D(M_src, 0, floor((DimSize(M_src,1)-1)/2), 3, 0, "W_profile_x")
```

### 2D image 上で有限幅 line profile を作る
```igorpro
Wave M_src = M_ImagePlane
SliceWB_WideLineProfile2DByPoint(M_src, 20, 20, 180, 80, 7, 300, 0, "W_band")
```

## 次にやると良いこと
- この core の上に panel を被せる
- 3D/4D の slab 厚みスライダを付ける
- 2D の arbitrary line 用に start/end マーカーを panel 上でドラッグできるようにする
- wide line の mode に median を追加する
