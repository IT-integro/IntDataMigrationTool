{{#forEach this.workItems}} 
    {{#if isFirst}} 
        {{#if (eq (lookup this.fields 'System.WorkItemType') 'Issue')}}
|{{this.id}}|{{{lookup this.fields 'System.Description'}}}|
        {{/if}}
    {{/if}}
{{/forEach}}