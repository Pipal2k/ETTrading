Adding a new Signal:

- ETDataTypes.mqh

	.) define new SIG
	.) adding to enum WhereOperantFunc 

- ETSignalSyszem.mqh
	
	.) implement in PrintSignalForDebug()

- ETSignalProcessing.mqh

	.) implement Processing for the new Signal (dont forget to fill metainfo)

- ETActionPatternParser.mqh

	.) implement in StringToBitFlag()
	.) implement in mapOperantFunc()


- ETActionPatternMatch.mqh
        .) implement in getFuncValue()
        
 ------------------------------------------------------------
 
 Adding new Where Function
 
 - ETDataTypes.mqh 
 .) define new iFunc in WhereOperantFunc
 
 - ETActionPatternParser.mqh
  .) add mapping to mapOperantFunc   
  .) add attribute to mapOperantFuncAttribute (Optional) 