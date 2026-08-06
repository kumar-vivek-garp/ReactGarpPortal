/**
* @File Name : ObjectDataDeleter.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : July 3, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 3, 2025 |   | Initial Version
**/

public class ObjectDataDeleter {
  // 1. Get Main Object Records
    @AuraEnabled(cacheable=true)
    public static List<SObject> getMainObjectRecords(String objectName, String filter, List<String> parentRelationships) {
        if (String.isBlank(objectName)) return new List<SObject>();
        
        // Build SELECT fields with parent relationship fields
        String selectFields = 'Id, Name';
        for (String rel : parentRelationships) {
            if (!String.isBlank(rel)) {
                selectFields += ', ' + rel + '.Id, ' + rel + '.Name';
            }
        }
        
        String soql = 'SELECT ' + selectFields + ' FROM ' + objectName;
        
        // IMPORTANT: filter can include parent fields e.g. Owner.Name = 'John Doe'
        if (String.isNotBlank(filter)) {
            soql += ' WHERE ' + filter;
        }
        soql += ' LIMIT 100';
        
        System.debug('SOQL: ' + soql);
        
        return Database.query(soql);
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<SObject>> getMultipleChildRelationships(
        List<Id> parentIds,
        List<String> childObjectNames,
        List<String> lookupFields
    ) {
        Map<Id, List<SObject>> resultMap = new Map<Id, List<SObject>>();
        
        for (Integer i = 0; i < childObjectNames.size(); i++) {
            String childObject = childObjectNames[i].trim();
            String lookupField = lookupFields[i].trim();
            
            if (String.isNotBlank(childObject) && String.isNotBlank(lookupField)) {
                String soql = 'SELECT Id, Name, ' + lookupField + ' FROM ' + childObject + ' WHERE ' + lookupField + ' IN :parentIds';
                List<SObject> children = Database.query(soql);
                
                for (SObject child : children) {
                    Id parentId = (Id)child.get(lookupField);
                    if (!resultMap.containsKey(parentId)) {
                        resultMap.put(parentId, new List<SObject>());
                    }
                    resultMap.get(parentId).add(child);
                }
            }
        }
        
        return resultMap;
    }

    // 3. Get Parent and Parent-of-Parent Records
    @AuraEnabled
    public static Map<Id, Map<String, SObject>> getParentHierarchy(
        List<SObject> records,
        List<String> parentRelationshipPaths
    ) {
        Map<Id, Map<String, SObject>> parentMap = new Map<Id, Map<String, SObject>>(); 
        for (SObject rec : records) {
            Map<String, SObject> relationships = new Map<String, SObject>();

            for (String path : parentRelationshipPaths) {
                String cleanPath = path.trim();
                if (String.isNotBlank(cleanPath)) {
                    try {
                        SObject value = rec;
                        for (String rel : cleanPath.split('\\.')) {
                            if (value != null) {
                                value = value.getSObject(rel);
                            }
                        }
                        if (value != null) {
                            relationships.put(cleanPath, value);
                        }
                    } catch (Exception e) {
                        System.debug('Could not resolve path ' + cleanPath + ': ' + e.getMessage());
                    }
                }
            }

            parentMap.put((Id)rec.get('Id'), relationships);
        }

        return parentMap;
    }

    // 4. Delete Main Object Records
    @AuraEnabled
    public static void deleteRecords(List<Id> recordIds, String objectName) {
        if (recordIds.isEmpty() || String.isBlank(objectName)) return;

        String soql = 'SELECT Id FROM ' + objectName + ' WHERE Id IN :recordIds';
        List<SObject> recordsToDelete = Database.query(soql);
        delete recordsToDelete;
    }
}