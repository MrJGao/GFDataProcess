PRO GetXmlValue,xmlFile,TagName,Value=Value,errorfile=errorFile,flag=flag
  ;    xmlFile='D:\djk\Xml\HJ1A-CCD1-1-64-20100406-L20000279007.XML'
  ;    TagName='zone'
  flag=0
  oDocument = OBJ_NEW('IDLffXMLDOMDocument', FileName = xmlFile)
  oPlugin = oDocument->GetFirstChild()
  oNodeList = oPlugin->GetElementsByTagName(TagName)
  nodeLen = oNodeList->Getlength()
  IF nodeLen LT 1 THEN BEGIN
    IF N_ELEMENTS(errorfile) NE 0 THEN BEGIN
      OPENW,lun,errorFile,/GET_LUN,/APPEND
      PRINTF,lun,'Tag cannot find in xml file! TagName: ',TagName
      PRINTF,lun,'XML file: ',xmlfile
      FREE_LUN,lun
    ENDIF
    RETURN
  ENDIF
  nodeObj = oNodeList->Item(0)
  oTextObj = nodeObj->GetFirstChild()
  IF OBJ_VALID(oTextObj) THEN BEGIN
    Value= oTextObj->GetNodeValue()
    flag=1
  ENDIF ELSE BEGIN
    Value=''
  ENDELSE
END

;RadiometricCalibration for GF-1
PRO ENVITask_RadiometricCalibration
  ; Start the application
  e = ENVI(/Headless)
  
  inputPath='F:\HXFarm\GF1'
  ; Open an input file
  Files = FILE_SEARCH(inputPath,'*.tiff',/FOLD_CASE,count=count)
  print,'All ',count,'    scenes will Radiometriccalibration'
  FOR i=0,count-1 DO BEGIN
    
    FilePath= file_dirname(Files[i])
    FileXmlfile=FilePath+'\'+FILE_BASENAME(Files[i],'.tiff',/FOLD_CASE)+'.xml'
    
    TagName='ReceiveTime'
    GetXmlValue,FileXmlfile,TagName,Value=Value,errorfile=errorFile,flag=flag
    ReceiveTime = Value
    
    ACQUISITION_TIME=STRJOIN(STRSPLIT(ReceiveTime, /EXTRACT), 'T')+'Z'
    
    TagName='SensorID'
    GetXmlValue,FileXmlfile,TagName,Value=Value,errorfile=errorFile,flag=flag
    SensorName = Value
    
    TagName='CloudPercent'
    GetXmlValue,FileXmlfile,TagName,Value=Value,errorfile=errorFile,flag=flag
    Cloud_cover = Value
    
    ;SensorName=STRMID(file_basename(Files[i],/FOLD_CASE),4,4)
    
    Raster = e.OpenRaster(Files[i])
    
    ; Define gains and offsets for a GF1 file saved
    CASE (SensorName) OF
      "PMS1": BEGIN
        Gains = [0.2082,0.1672,0.1748,0.1883]
        Offsets = [4.6186,4.8768,4.8924,-9.4771]
      END
      "PMS2": BEGIN
        Gains = [0.2072,0.1776,0.177,0.1909]
        Offsets = [7.5348,3.9395,-1.7445,-7.2053]
      END
      "WFV1": BEGIN
        Gains = [0.1709,0.1398,0.1195,0.1338]
        Offsets = [-0.0039,-0.0047,-0.003,-0.0274]
      END
      "WFV2": BEGIN
        Gains = [0.1588,0.1515,0.1251,0.1209]
        Offsets = [5.5303,-13.642,-15.382,-7.985]
      END
      "WFV3": BEGIN
        Gains = [0.1556,0.17,0.1392,0.1354]
        Offsets = [12.28,-7.9336,-7.031,-4.3578]
      END
      "WFV4": BEGIN
        Gains = [0.1819,0.1762,0.1463,0.1522]
        Offsets = [3.6469,-13.54,-10.998,-12.142]
      END
    ENDCASE
    
    
    Metadata = raster.Metadata
    
    metadataTags = Raster.Metadata.Tags

    ; If these three tags exist, the raster is a classification raster
    isClassRaster = metadataTags.HasValue('DATA GAIN VALUES')
    
    IF (isClassRaster eq 1) THEN BEGIN
      Metadata.UpdateItem,'data gain values', Gains
    ENDIF ELSE BEGIN
      Metadata.AddItem,'data gain values', Gains
    ENDELSE
    
    isClassRaster = metadataTags.HasValue('DATA OFFSET VALUES')
    
    IF (isClassRaster eq 1) THEN BEGIN
      Metadata.UpdateItem,'data offset values', Offsets
    ENDIF ELSE BEGIN
      Metadata.AddItem,'data offset values', Offsets
    ENDELSE

    ;is the metadataTags exist?
    isMetadataRaster = metadataTags.HasValue('WAVELENGTH UNITS')
    ; Add metadata to raster.
    IF (isMetadataRaster eq 1) THEN BEGIN
      ;if the tags existed, update them
      raster.Metadata.UpdateItem,'WAVELENGTH UNITS','Micrometers'
    ENDIF ELSE BEGIN
      ;or add the new tags
      raster.Metadata.AddItem,'WAVELENGTH UNITS','Micrometers'
    ENDELSE

    ;is the metadataTags exist?
    isMetadataRaster = metadataTags.HasValue('WAVELENGTH')
    ; Add metadata to raster.
    IF (isMetadataRaster eq 1) THEN BEGIN
      ;if the tags existed, update them
      raster.Metadata.UpdateItem,'WAVELENGTH',[0.4850,0.5600,0.6960,0.7970]
    ENDIF ELSE BEGIN
      ;or add the new tags
      raster.Metadata.AddItem,'WAVELENGTH',[0.4850,0.5600,0.6960,0.7970]
    ENDELSE

    ;is the metadataTags exist?
    isMetadataRaster = metadataTags.HasValue('FWHM')
    ; Add metadata to raster.
    IF (isMetadataRaster eq 1) THEN BEGIN
      ;if the tags existed, update them
      raster.Metadata.UpdateItem,'FWHM',[0.05702,0.08318,0.08055,0.12760]
    ENDIF ELSE BEGIN
      ;or add the new tags
      raster.Metadata.AddItem,'FWHM',[0.05702,0.08318,0.08055,0.12760]
    ENDELSE

    isMetadataRaster = metadataTags.HasValue(strupcase('sun azimuth'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'sun azimuth',[173.724]
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'sun azimuth',[173.724]
    ENDELSE

    isMetadataRaster = metadataTags.HasValue(strupcase('sun elevation'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'sun elevation',[22.704000]
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'sun elevation',[22.704000]
    ENDELSE

    isMetadataRaster = metadataTags.HasValue(strupcase('solar irradiance'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'solar irradiance',[1.99643000e+003, 1.84904000e+003, 1.52788000e+003, 1.06524000e+003]
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'solar irradiance',[1.99643000e+003, 1.84904000e+003, 1.52788000e+003, 1.06524000e+003]
    ENDELSE

    isMetadataRaster = metadataTags.HasValue(strupcase('sensor type'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'sensor type' ,'GF-1'
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'sensor type' ,'GF-1'
    ENDELSE

    isMetadataRaster = metadataTags.HasValue(strupcase('product type'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'product type' ,'STANDARD'
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'product type' ,'STANDARD'
    ENDELSE
    
    isMetadataRaster = metadataTags.HasValue(strupcase('sensor'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'sensor',SensorName
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'sensor',SensorName
    ENDELSE
    
    isMetadataRaster = metadataTags.HasValue(strupcase('time'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'time',ACQUISITION_TIME
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'time',ACQUISITION_TIME
    ENDELSE
    
    isMetadataRaster = metadataTags.HasValue(strupcase('cloud cover'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'cloud cover',Cloud_cover
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'cloud cover',Cloud_cover
    ENDELSE
    
    ; Get the radiometric calibration task from the catalog of ENVI tasks
    Task = ENVITask('RadiometricCalibration')

    ; Define inputs. Since radiance is the default calibration
    ; method, we do not need to specify it here.
    Task.Input_Raster = Raster
    Task.Output_Data_Type = 'Float'
    Task.SCALE_FACTOR =0.10

    OutPath= file_dirname(Files[i])
    outputfile=OutPath+'\'+FILE_BASENAME(Files[i],'.tiff',/FOLD_CASE)+'_rc.dat'

    ; Define output raster URI
    Task.Output_Raster_URI = outputfile
    
    output = File_Search(outputfile)

    fileCount1 = SIZE(output)
    if fileCount1[0] gt 0 then begin
      print,outputfile+' is already exist'
      continue
    endif
    
    print,'The',i+1,'   scene      start',outputfile
    ; Run the task
    Task.Execute
    print,'The',i+1,'   scene      finished',outputfile
      
  ENDFOR
  print,'All files RadiometricCalibration OK!'
END