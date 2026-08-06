/**
* Class TriggerFactory
*
* Used to instantiate and execute Trigger Handlers associated with sObjects.
*/
public with sharing class TriggerFactory{
    /**
* Public static method to create and execute a trigger handler
*
* Arguments:   Type t - Type of handler to instatiate
*
* Throws a TriggerException if no handler has been found.
*/
    public static void createAndExecuteHandler(Type t){
        
        SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
        String sObjectName = triggerType.getDescribe().getName();
        system.debug('TriggerFactory  createAndExecuteHandler  sObjectName::>>  '+sObjectName);
        Map<String,String> triggerSettings = TriggerUtil.triggerConfigurations(sObjectName);
        //system.debug(triggerSettings.size()+'  TriggerFactory  createAndExecuteHandler  triggerSettings::>>  '+triggerSettings);
        
        // Get a handler appropriate to the object being processed
        TriggerAbstract handler = getHandler(t);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null){
            throw new TriggerException('No Trigger Handler found named: ' + t.getName());
        }
        
        // Execute the handler to fulfil the trigger
        if(triggerSettings.size() > 0){
           execute(handler,triggerSettings);
        }else{
            execute(handler);
        }
        
    }
    
    /**
* private static method to control the execution of the handler
*
* Arguments:   TriggerAbstract handler - A Trigger Handler to execute
*/
    private static void execute(TriggerAbstract handler, Map<String,String> triggerSettingsMDT){
        // Before Trigger
        String loggedInUserID = UserInfo.getUserId().substring(0,15);
		Boolean skipExecutionForUser = False;
		if(triggerSettingsMDT.get('Users_To_Skip') == null || (triggerSettingsMDT.get('Users_To_Skip') != null && triggerSettingsMDT.get('Users_To_Skip').contains(loggedInUserID))){
			skipExecutionForUser = True;
		}
		
        if (Trigger.isBefore){
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete){
				if(triggerSettingsMDT.get('Skip_for_Before_Delete') == 'True' && skipExecutionForUser){
					system.debug('  **** TriggerFactory - Skip Before Delete ***');
				}else{
					for (SObject so : Trigger.old){
						handler.beforeDelete(so);
					}
				}
			}
			
			// Iterate through the records to be inserted passing them to the handler.	  
			else if(Trigger.isInsert){
				if(triggerSettingsMDT.get('Skip_for_Before_Insert') == 'True' && skipExecutionForUser){
					system.debug('  **** TriggerFactory - Skip Before Insert ***');
				}else{
					for (SObject so : Trigger.new){
						handler.beforeInsert(so);
					}
				}
			}
			
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate){
				if(triggerSettingsMDT.get('Skip_for_Before_Update') == 'True' && skipExecutionForUser){
					system.debug('  **** TriggerFactory - Skip Before Update ***');
				}else{
					for (SObject so : Trigger.old){
						handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
					}
				}
			} 
        }
        else{
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete){
				if(triggerSettingsMDT.get('Skip_for_After_Delete') == 'True' && skipExecutionForUser){
					system.debug('  **** TriggerFactory - Skip After Delete ***');
				}else{
					for (SObject so : Trigger.old){
						handler.afterDelete(so);
					}
				}
			} 
			
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert){
				if(triggerSettingsMDT.get('Skip_for_After_Insert') == 'True' && skipExecutionForUser){
					system.debug('  **** TriggerFactory - Skip After Insert ***');
				}else{
					for (SObject so : Trigger.new){
						 handler.afterInsert(so);
					 }
				}
			} 
			
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate){
				if(triggerSettingsMDT.get('Skip_for_After_Update') == 'True' && skipExecutionForUser){
					system.debug('  **** TriggerFactory - Skip After Update ***');
				}else{
					for (SObject so : Trigger.old){
                             handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                         }
				}
			}
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    private static void execute(TriggerAbstract handler){
        if (Trigger.isBefore){
            handler.bulkBefore();
            if (Trigger.isDelete){
                for (SObject so : Trigger.old){
                    handler.beforeDelete(so);
                }
            }
            else if (Trigger.isInsert){
                for (SObject so : Trigger.new){
                    handler.beforeInsert(so);
                }
            }
            else if (Trigger.isUpdate){
                for (SObject so : Trigger.old){
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        else{
            handler.bulkAfter();
            if (Trigger.isDelete){
                for (SObject so : Trigger.old){
                    handler.afterDelete(so);
                }
            }
            else if (Trigger.isInsert){
                for (SObject so : Trigger.new){
                    handler.afterInsert(so);
                }
            }
            else if (Trigger.isUpdate){
                for (SObject so : Trigger.old){
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        handler.andFinally();
    }
    
    /**
* private static method to get the named handler.
*
* Arguments:   Type t - Class of handler to instatiate
*
* Returns:     TriggerAbstract - A trigger handler if one exists or null.
*/
    private static TriggerAbstract getHandler(Type t){
        // Instantiate the type
        Object o = t.newInstance();
        
        // if its not an instance of TriggerAbstract return null
        if (!(o instanceOf TriggerAbstract)){
            return null;
        }
        
        return (TriggerAbstract)o;
    }
    
    public class TriggerException extends Exception {}
}