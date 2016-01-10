Adding a new Signal:

- ETDataTypes.mqh

	.) define new SIG
	.) adding to enum WhereOperantFunc 

- ETSignalSyszem.mqh
	
	.) implement in PrintSignalForDebug()

- ETSignalProcessing.mqh

	.) implement Processing for the new Signal (dont forget to fill metainfo)

- ETActionPattern.mqh

	.) implement in StringToBitFlag()
	.) implement in mapOperantFunc()


- ETActionPatternMatch.mqh
        .) implement in getFuncValue()