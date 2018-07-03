view wave 
wave clipboard store
wave create -driver freeze -pattern constant -value 10 -range 1 0 -starttime 0ps -endtime 1000ps sim:/maq_emissora/estado 
WaveExpandAll -1
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/maq_emissora/op 
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/maq_emissora/estado_op 
wave create -driver expectedOutput -pattern constant -value 11 -range 1 0 -starttime 0ps -endtime 1000ps sim:/maq_emissora/emissor_bus 
wave create -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps sim:/maq_emissora/bit_escolha 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/estado_op 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/op 
wave modify -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/estado_op 
wave modify -driver freeze -pattern constant -value 01 -range 1 0 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/estado 
wave modify -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/op 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/estado_op 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/op 
wave modify -driver freeze -pattern constant -value 00 -range 1 0 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/estado 
wave modify -driver freeze -pattern constant -value 0 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/op 
wave modify -driver freeze -pattern constant -value 01 -range 1 0 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/estado 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ps -endtime 1000ps Edit:/maq_emissora/op 
WaveCollapseAll -1
wave clipboard restore
