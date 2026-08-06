public class GBI_Common {

    public static Set<String> getPickListValues(String strObjectName, String strPicklistField) {

        Set<String> retValues = new Set<String>();
            
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            retValues.add(objPickList.getLabel());
        }
        
        return retValues;
    }
    
    public static void debugLog(String className, String methodName, String msg, Object values) {
        if(msg == NULL)
            return;
        
        if(Label.GARP_Debugging == 'TRUE') {
            String str='';
            if(className != NULL) {
                str+=className;
            }
            if(methodName!=NULL) {
                if(!String.isEmpty(str))
                    str+=':';
                str+=methodName;
            }
            if(msg!=NULL) {
                if(!String.isEmpty(str))
                    str+=':';
                str+=msg;
            }
            String val = String.ValueOf(values);
            if(val!=NULL) {
                if(!String.isEmpty(str))
                    str+=':';
                str+=val;
            }
            System.debug(str);
        }
    }
    
}