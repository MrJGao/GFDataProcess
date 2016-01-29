PRO ENVITask_QUAC
  ; Start the application
  e = ENVI()
  
  inputPath='D:\HXFarm\GF1'
  
  ; Open an input file
  Files = FILE_SEARCH(inputPath,'*_rc.dat',/FOLD_CASE,count=count)
  
  print,'共',count,'    景影像进行快速大气纠正'

  FOR i=0,count-1 DO BEGIN
    Raster = e.OpenRaster(Files[i])
    outPath= file_dirname(Files[i])
    ; Get the QUAC task from the catalog of ENVITasks
    Task = ENVITask('QUAC')
    
    ; Define inputs
    Task.INPUT_RASTER = Raster
    ;Task.SENSOR = 'Landsat TM'
    
    outputfile=outPath+'\'+FILE_BASENAME(Files[i],'.dat',/FOLD_CASE)+'_quac.dat'
    print,'the',i+1,'scene start     ',outputfile
    Task.OUTPUT_RASTER_URI = outputfile
    print,'the',i+1,'scene finished     ',outputfile
    output = File_Search(outputfile)

    fileCount1 = SIZE(output)
    if fileCount1[0] gt 0 then begin
      print,outputfile+' is already exist'
      continue
    endif
    
    ; Run the task
    Task.Execute
  ENDFOR
  ;  ; Get the data collection
  ;  DataColl = e.Data
  ;
  ;  ; Add the output to the data collection
  ;  DataColl.Add, Task.OUTPUT_RASTER
  ;
  ;  ; Display the result
  ;  View1 = e.GetView()
  ;  Layer1 = View1.CreateLayer(Task.Output_Raster)
  print,'QUAC is OK!'
END