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

PRO ENVITask_writemetadata
  e = ENVI()
  
  inputPath='D:\HXFarm\GF1'
  ; Open an input file
  Files = FILE_SEARCH(inputPath,'*_rc.dat',/FOLD_CASE,count=count)

  FOR i=0,count-1 DO BEGIN
    
    FilePath= file_dirname(Files[i])
    FileXmlfile=FilePath+'\'+FILE_BASENAME(Files[i],'_rc.dat',/FOLD_CASE)+'.xml'
    
    TagName='ReceiveTime'
    GetXmlValue,FileXmlfile,TagName,Value=Value,errorfile=errorFile,flag=flag
    ReceiveTime = Value
    ACQUISITION_TIME=STRJOIN(STRSPLIT(ReceiveTime, /EXTRACT), 'T')+'Z'
    
    ; Open the input Raster
    Raster = e.OpenRaster(Files[i])
    
    FID = ENVIRasterToFID(Raster)
    
    ;Get the metadata of input Raster
    Metadata = Raster.Metadata
    ;Get the metadataTags of input Raster
    metadataTags = Raster.Metadata.Tags
    
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
    
    isMetadataRaster = metadataTags.HasValue(strupcase('time'))
    IF (isMetadataRaster eq 1) THEN BEGIN
      raster.Metadata.UpdateItem,'time',ACQUISITION_TIME
    ENDIF ELSE BEGIN
      raster.Metadata.AddItem,'time',ACQUISITION_TIME
    ENDELSE
    
    ;acquisition time = 2015-01-26T03:17:48Z
    ;sensor = WFV4
  
    ; Update the ENVI format *.hdr file with new metadata.
    raster.WriteMetadata
  ENDFOR
  
END