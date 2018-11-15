<aura:application extends="force:slds">
    <c:SK_GenericTreeGridCmp ltngcurrentRecId="0019000000ld4kS"
                                     ltngSobjectName="Account"
                                     ltngParentFieldAPIName="ParentId"
                                     ltngColumnLabelList="['Name','Type','Industry','Account Owner']"
                                     ltngColumnAPINameList="['Name','Type','Industry','Owner.Name']"
                                     ltngHyperlinkColumn="Name"/>
     
        
            <c:SK_GenericTreeGridCmp ltngcurrentRecId="5009000000GJkJE"
                                     ltngSobjectName="Case"
                                     ltngParentFieldAPIName="ParentId"
                                     ltngColumnLabelList="['CaseNumber','Subject','Status','Case Owner','Case Owner Email','Account Owner']"
                                     ltngColumnAPINameList="['CaseNumber','Subject','Status','Owner.Name','Owner.Email','Account.Owner.Name']"
                                     ltngHyperlinkColumn="CaseNumber"
                                     ltngHeaderValue="Case Hierarchy"/>
        

   
</aura:application>