;PRO getFileFromFolder,inputPath,ExtensionName,Files=Files
;  ;inputPath='D:\77211356\Data\GF\HuBei\wuhan'
;  ;ExtensionName='*.tiff'
;  Files=FILE_SEARCH(inputPath,ExtensionName,/FOLD_CASE,count=count)
;  
;;  FOR i=0,count-1 DO BEGIN
;;    ;获取文件的路径，不包含文件名
;;    path=file_dirname(Files[i],/MARK_DIRECTORY)
;;    ;print,path
;;    ;获取文件名
;;    file=FILE_BASENAME(Files[i])
;;    ;print,file
;;    
;;  ENDFOR
;END


PRO ENVITask_rpcorthorectification
  ; 启动ENVI5.x
  e = ENVI(/HEADLESS)
  
  inputPath='D:\HXFarm\GF1'
  
  Files=FILE_SEARCH(inputPath,'*_rc_quac.dat',/FOLD_CASE,count=count)

  print,'共',count,'    景影像正射校正'
  
  FOR i=0,count-1 DO BEGIN
    
    ;获取文件的路径，不包含文件名
    ;path=file_dirname(Files[i],/MARK_DIRECTORY)
    ;print,path
    ;获取文件名
    ;file=FILE_BASENAME(Files[i])
    ;print,file

 
    ;输入影像
    ImageFile=Files[i]
    ;选择输入影像
    ;ImageFile = DIALOG_PICKFILE(TITLE='Select an input image',filter=fileExtension)
    Raster = e.OpenRaster(ImageFile)
    outPath= file_dirname(ImageFile)
    
    ;referenceFile = 'D:\HXFarm\ref\118_26_27.tif'
    ;referenceRaster = e.OpenRaster(referenceFile)
    
    
    ; DEM影像路径
    DEMFile = 'C:\Program Files\Exelis\ENVI52\data\GMTED2010.jp2'
    DEM = e.OpenRaster(DEMFile)
  
    ;
    Task = ENVITask('RPCOrthorectification')
    ;Task = ENVITask()
    ; 
    Task.INPUT_RASTER = Raster
    ;Task.INPUT_REFERENCE_RASTER = referenceRaster
    Task.DEM_RASTER = DEM
    Task.DEM_IS_HEIGHT_ABOVE_ELLIPSOID = 0
    
    Task.Output_Pixel_Size = 16
    ;Task.OUTPUT_INTERPOLATION_METHOD=2
    
    outputfile=outPath+'\'+FILE_BASENAME(ImageFile,'.dat',/FOLD_CASE)+'_rpc.dat'
    
    Task.OUTPUT_RASTER_URI = outputfile
  
    output = File_Search(outputfile)

    fileCount1 = SIZE(output)
    if fileCount1[0] gt 0 then begin
      print,outputfile+' is already exist'
      continue
    endif
    print,'第',i+1,'景      ',outputfile
    ;
    Task.Execute, Error=error
    ;
    ;DataColl = e.DATA
    ;DataColl.Add, Task.OUTPUT_RASTER
    ;
    ;View1 = e.GetView()
    ;Layer1 = View1.CreateLayer(Task.OUTPUT_RASTER)
    print,'第',i+1,'景影像正射校正完毕！'
  ENDFOR
  e.Close
  print,'全部影像正射校正完毕！'
END