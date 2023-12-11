public class Dynacat_Picklist_Deployments extends VisualEditor.DynamicPickList{
    
    public override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = null;
        for ( VisualEditor.DataRow row : getValues().getDataRows() ) {
            if ( row.isSelected() ) {
                defaultValue = row;
            }
        }
        return defaultValue;
    }
    
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows dataSources = new VisualEditor.DynamicPickListRows();
        List<Dynacat_Deployment__c> deployments = [SELECT Id, Name FROM Dynacat_Deployment__c ORDER BY Name ASC];
        for(Dynacat_Deployment__c d : deployments) dataSources.addRow(new VisualEditor.DataRow(d.Name, d.Name));
        return dataSources;
    }
}