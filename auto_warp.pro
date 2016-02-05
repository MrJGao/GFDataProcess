PRO Auto_WARP

  COMPILE_OPT idl2
  ENVI,/RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT,/NO_STATUS_WINDOW
  
  inputPath='D:\HXFarm\GF1'

  WarpFiles=FILE_SEARCH(inputPath,'_rpc.dat',/FOLD_CASE,count=count)
  
  print,'共',count,'    景影像几何校正'
  
  FOR i=0,count-1 DO BEGIN
  
    WarpFile=WarpFiles[i]
    
    outPath= file_dirname(WarpFile)
    
    out_name=outPath+'\'+FILE_BASENAME(WarpFile,'.tif',/FOLD_CASE)+'_warp.tif'
    
    BaseFile='D:\HXFarm\ref\118_26_27.tif'
    ;WarpFile='D:\77211356\Data\GF\HuBei\huanggang\20150122\GF1_WFV2_E115.9_N29.3_20150122_L1A0000606437\GF1_WFV2_E115.9_N29.3_20150122_L1A0000606437_rpc.tif'
    
    ;打开参考影像
    envi_open_file, BaseFile, r_fid=base_fid
    ;打开待纠正影像
    envi_open_file, WarpFile, r_fid=warp_fid
    ;如果为空则返回
    if (base_fid eq -1 || warp_fid eq -1) then begin
      envi_batch_exit
      return
    endif
    
    print,'第',i+1,'景      开始…………',out_name
    
    ;波段号，0为第一波段
    base_match_pos = 0L
    ;波段号，0为第一波段
    warp_match_pos = 0L
    ;控制点个数，适中，GF-1一整景影像一般530多-750（参考影像为TM8的全色）
    num_tie_points = 575
    ;移动窗口，默认为11，值越大越准，时间越长
    move_win = 11
    ;搜索窗口，默认为81，值越大越准，时间越长
    search_win = 255
    ;兴趣点搜索范围，值越大越准，时间越长
    area_chip_size = 128L
    ;默认为1，值越大越准，时间越长
    num_oversamples = 4
    ;设置控制点文件输出路径与文件名
    out_tie_points_name = outPath+'\'+FILE_BASENAME(WarpFile,'.tif',/FOLD_CASE)+'_tile.pts'
    print,'第',i+1,'景      控制点查找开始，文件名：',out_tie_points_name
    ;
    ; Perform the automatic tie point collection
    ;
    
    envi_doit, 'envi_auto_tie_points_doit', $
      base_fid=base_fid, $
      warp_fid=warp_fid, $
      base_match_pos=base_match_pos, $
      warp_match_pos=warp_match_pos, $
      num_tie_points=num_tie_points, $
      move_win=move_win, $
      search_win=search_win, $
      area_chip_size=area_chip_size, $
  ;    in_tie_points_array=in_tie_points_array, $
      num_oversamples=num_oversamples, $
      ;将控制点数组赋值到PTS中
      OUT_TIE_POINTS_ARRAY=pts,$
      ;将控制点文件输出到指定文件夹
      out_tie_points_name=out_tie_points_name
    
    print,'第',i+1,'景     控制点查找完毕 !    ',out_name
    ;待纠正影像的fid 
    fid=warp_fid
    ;
    ; Set the DIMS and POS to keywords
    ; to processes all spatial and all
    ; spectral data. Output the result
    ; to disk.
    ;
    envi_file_query, fid, dims=dims, nb=nb
    pos = lindgen(nb)
    
    
    ;out_name = 'D:\77211356\Data\GF\HuBei\basedata\Warp\GF1_WFV2_E115.9_N29.3_20150122_L1A0000606437_rpc_warp.tif'
  
    ;
    ; Perform the image-to-map registration.
    ;
    envi_doit, 'envi_register_doit', $
      B_FID=base_fid,$
      w_fid=fid, w_pos=pos, w_dims=dims, $
      method=2, out_name=out_name, $
      pts=pts,r_fid=r_fid  
      
    print,'第',i+1,'景影像几何校正完毕！'
    ;
    ; Exit ENVI Classic
    ;
  ENDFOR
    
  ENVI_batch_EXIT
  print,'全部影像几何校正完毕！'
END