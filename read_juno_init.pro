PRO READ_JUNO_INIT,parameters,file=file,verbose=verbose

if keyword_set(verbose) then verbose=1b else verbose=0b
if ~keyword_set(file) then file='juno_init.xml'


oDocument = OBJ_NEW('IDLffXMLDOMDocument')
oDocument->Load, FILENAME = file

oData = oDocument->GetFirstChild()
if verbose then message,/info,oData->GetNodeName()
oChild = oData->GetFirstChild()  
while obj_valid(oChild) do begin 
  nodeName = oChild->GetNodeName()
  case nodeName of 

; ------------------------------------------------------------------------------
    'SUN_LOCATION' : begin
      if verbose then message,/info,nodeName+':'  
      oChild1 = oChild->GetFirstChild()
      while obj_valid(oChild1) do begin 
        subNodeName = oChild1->GetNodeName()
        oChild2 = oChild1->GetFirstChild()
        case subNodeName of
          'LONGITUDE' : begin
            if verbose then message,/info,nodeName+'/'+subNodeName+' value = '+oChild2->GetNodeValue()
            local_time_0 = float(oChild2->GetNodeValue())
          end
          'INCLINATION' : begin
            if verbose then message,/info,nodeName+'/'+subNodeName+' value = '+oChild2->GetNodeValue()
            local_time_1 = float(oChild2->GetNodeValue())
          end
          '#text' :
          else : message,/info,nodeName+'/'+subNodeName+': Illegal tag. Skipping.'
        endcase
        oChild1 = oChild1->GetNextSibling()
      endwhile
    end

; ------------------------------------------------------------------------------
    'SIMULATION' : begin
      if verbose then message,/info,nodeName+':'  
      oChild1 = oChild->GetFirstChild()
      while obj_valid(oChild1) do begin 
        subNodeName = oChild1->GetNodeName()
        oChild2 = oChild1->GetFirstChild()
        case subNodeName of
          'LENGTH' : begin
            if verbose then message,/info,nodeName+'/'+subNodeName+' value = '+oChild2->GetNodeValue()
            simul_length = float(oChild2->GetNodeValue())
          end
          'STEP' : begin
            if verbose then message,/info,nodeName+'/'+subNodeName+' value = '+oChild2->GetNodeValue()
            simul_step = float(oChild2->GetNodeValue())
          end
          '#text' :
          else : message,/info,nodeName+'/'+subNodeName+': Illegal tag. Skipping.'
        endcase
        oChild1 = oChild1->GetNextSibling()
      endwhile
    end

; ------------------------------------------------------------------------------
    'FREQUENCY' : begin
      print,'reading Frequency parameters'
    end

; ------------------------------------------------------------------------------
    'OBSERVER' : begin
      print,'reading Observer parameters'
    end

; ------------------------------------------------------------------------------
    'SOURCES'  : begin 
      print,'reading Sources parameters'
    end

; ------------------------------------------------------------------------------
    '#text'       : 
    else : stop
  endcase

; ------------------------------------------------------------------------------
  oChild = oChild->GetNextSibling()  
endwhile
stop
END