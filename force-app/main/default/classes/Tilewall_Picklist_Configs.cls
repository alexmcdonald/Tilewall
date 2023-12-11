public class Tilewall_Picklist_Configs extends VisualEditor.DynamicPickList{
    
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
        List<Tilewall_Config__c> configs = [SELECT Id, Name FROM Tilewall_Config__c ORDER BY Name ASC];
        for(Tilewall_Config__c c : configs) dataSources.addRow(new VisualEditor.DataRow(c.Name, c.Name));
        return dataSources;
    }
}