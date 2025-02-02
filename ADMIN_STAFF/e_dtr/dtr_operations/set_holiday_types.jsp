<%@ page language="java" import="utility.*,java.util.Vector,eDTR.Holidays" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script>
<!--

function AddRecord(){
	document.dtr_op.page_action.value ="1";
	document.dtr_op.submit();
}
function DeleteRecord(strTargetIndex)
{
	document.dtr_op.info_index.value = strTargetIndex;
	document.dtr_op.page_action.value = "0";
	document.dtr_op.submit();
}
function EditRecord(){
	document.dtr_op.page_action.value = "2";
	document.dtr_op.submit();
}

function PrepareToEdit(strIndex){
	document.dtr_op.prepareToEdit.value = "1";
	document.dtr_op.info_index.value = strIndex;
	document.dtr_op.submit();
}

function CloseWindow()
{
	window.opener.document.dtr_op.submit()
	window.opener.focus();
	self.close();
}

function CancelRecord(){
	location = "./set_holiday_types.jsp";
}

function updateType(){	
	var loadPg = "./holiday_group/holiday_type_mgmt.jsp?hide_back=1&opner_form_name=form_" +
       	 "&opner_form_field=holiday_type_index"+
				 "&opner_form_field_value="+document.dtr_op.holiday_type_index.value;
	var win=window.open(loadPg,"updateType",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
//	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
//	"&opner_form_name=form_";
	//document.form_.donot_call_close_wnd.value="0";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-DTR OPERATIONS","set_holiday_types.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"set_holiday_types.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo= null;
Holidays hol = new Holidays();
boolean bolFatalErr = true;
String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

int iPageAction = Integer.parseInt(WI.getStrValue(strPageAction,"4"));

switch (iPageAction){
  case 1: {	if (hol.operateOnHolidayRates(dbOP,request,iPageAction) != null) 
				strErrMsg = " Holiday rate added successfully ";
			else strErrMsg = hol.getErrMsg();
			
			break;
		  }
 case 2: {
			if (hol.operateOnHolidayRates(dbOP,request,iPageAction) != null){
				strErrMsg = " Holiday rate edited successfully ";
				strPrepareToEdit = "";
			}else
				strErrMsg = hol.getErrMsg();

			break;
		 }
 case 0:{
			if (hol.operateOnHolidayRates(dbOP,request,iPageAction) != null)
							strErrMsg = " Holiday rate removed successfully ";
			else
				strErrMsg = hol.getErrMsg();
			
			break;
		}
} // end switch

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = hol.operateOnHolidayRates(dbOP,request,3);

	if (vEditInfo == null)
		strErrMsg = hol.getErrMsg();
	
}

vRetResult  = hol.operateOnHolidayRates(dbOP, request, 4);
%>
<form action="./set_holiday_types.jsp" method="post" name="dtr_op">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      HOLIDAY TYPES MAINTENANCE PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size=3><strong><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2">Holiday Group </td>
      <td><strong>
        <% 
				if(vEditInfo !=null)  
					strTemp = (String)vEditInfo.elementAt(40);   
				else 
					strTemp = WI.fillTextValue("holiday_type"); 
			%>
        <select name="group_index">
          <option value="">Default group</option>
          <%=dbOP.loadCombo("h_group_index","group_name"," from EDTR_HOLIDAY_GROUP " +
 					"order by group_name asc",strTemp, false)%>
        </select>
      </strong>        
			<a href='javascript:viewList("EDTR_HOLIDAY_GROUP","h_group_index","group_name",
						 "Holiday Groupings", "EDTR_HOLIDAY_RATE, EDTR_EMP_HOL_GROUP", 
						 "H_GROUP_INDEX, H_GROUP_INDEX",
						 " and is_valid = 1,  and is_valid = 1",
						 "","group_index");'><img src="../../../images/update.gif" border="0" ></a>			</td>
    </tr>
    <tr> 
      <td height="25" colspan="2"> Holiday Type</td>
      <td width="589"> 
			<% 			
				if(vEditInfo !=null)
					strTemp = (String)vEditInfo.elementAt(42);  
				else 
					strTemp = WI.fillTextValue("holiday_type_index"); 
			%> 
	 	  <strong>
	 	  <select name="holiday_type_index">
        <option value="">Select Holiday type</option>
        <%=dbOP.loadCombo("holiday_type_index","type"," from edtr_holiday_type where is_del = 0 " +
					"order by TYPE asc",strTemp, false)%>
      </select>
	 	  <a href='javascript:updateType();'><img src="../../../images/update.gif" border="0" ></a></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
      <td><% 
				if(vEditInfo !=null)  
					strTemp = (String)vEditInfo.elementAt(38);   
				else 
					strTemp = WI.fillTextValue("present_before"); 
					
				if(strTemp != null && strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
			%>
        <input type="checkbox" value="1" name="present_before" <%=strTemp%>>
      Should be present on the last working day before holiday</td>
    </tr>
    <tr> 
      <td height="26" colspan="3" valign="bottom"><strong>Employee's regular workday</strong>      </td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><u>If Unworked : </u></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="36" height="26">&nbsp;</td>
      <td width="145">Rate/Unit</td>
      <td height="26"><strong> </strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2"> <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(2);
	  else strTemp = WI.fillTextValue("RW_UW_RPU_UNIT"); %> <select name="RW_UW_RPU_UNIT" >
          <option value="0">Equal</option>
          <% if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Plus</option>
          <%}else{%>
          <option value="1">Plus</option>
          <%}%>
        </select> <% if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
	  else strTemp = WI.fillTextValue("RW_UW_RPU_VALUE"); %> <input name="RW_UW_RPU_VALUE" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RW_UW_RPU_VALUE')"
	 onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RW_UW_RPU_VALUE')" value="<%=strTemp%>" size="6" maxlength="6"> 
        <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(4);
	  else strTemp = WI.fillTextValue("RW_UW_RPU_PERCENT"); %> <select name="RW_UW_RPU_PERCENT" >
          <option value="0">Percentage</option>
          <%if (strTemp.equals("1")){%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select> <select name="RW_UW_RPU_PERCENT_UNIT" >
          <option value="0">Hourly Rate</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(5);
	  else strTemp = WI.fillTextValue("RW_UW_RPU_PERCENT_UNIT"); 

		  if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Per Day Rate</option>
          <%}else{%>
          <option value="1">Per Day Rate</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><u>If Worked : </u></td>
      <td >&nbsp; </td>
    </tr>
    <tr> 
      <td height="26"><div align="right">a.)&nbsp;&nbsp;&nbsp;</div></td>
      <td>Rate/Unit (First)</td>
      <td height="26"><strong> </strong> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> <% if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
	  else strTemp = WI.fillTextValue("RW_W_1ST_VALUE"); %> <input name="RW_W_1ST_VALUE" type="text"  size="2" maxlength="2" value="<%=strTemp%>"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RW_W_1ST_VALUE')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RW_W_1ST_VALUE')" class="textbox" > 
        <select name="RW_W_1ST_UNIT" >
          <option value="0">Hours</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(7);
	  else strTemp = WI.fillTextValue("RW_W_1ST_UNIT"); 
	  
		 if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Minutes</option>
          <%}else{%>
          <option value="1">Minutes</option>
          <%}%>
        </select>
        : </td>
      <td height="25"><select name="RW_W_1ST_RU" >
        <option value="0">Equal</option>
        <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(8);
	  else strTemp = WI.fillTextValue("RW_W_1ST_RU"); 
	  
	  if (strTemp.compareTo("1")  == 0){%>
        <option value="1" selected>Plus</option>
        <%}else{%>
        <option value="1">Plus</option>
        <%}%>
      </select>
        <% if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(9));
	  else strTemp = WI.fillTextValue("RW_W_1ST_RU_VAL");  %> <input name="RW_W_1ST_RU_VAL" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RW_W_1ST_RU_VAL')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RW_W_1ST_RU_VAL')"  value="<%=strTemp%>" size="6" maxlength="6"> 
        <select name="RW_W_1ST_RU_PERCENT" >
          <option value="0">Percentage</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(10);
	  else strTemp = WI.fillTextValue("RW_W_1ST_RU_PERCENT");  
	  	
			if (strTemp.compareTo("1")  == 0) {%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select>
        of 
        <% 
				if (vEditInfo != null)  
					strTemp = WI.getStrValue((String)vEditInfo.elementAt(11));
			  else 
					strTemp = WI.fillTextValue("RW_W_1ST_RU2"); %> 		
			<!-- 
				2011-09-07  - harvey
				these two fields below are annoying. to those who do not really know  the computation 
				of holidays di jud makasabot...
				ang mahitabo man gud ani ang maging statement
				sample: unworked
				equals 100% of 100% of daily rate... toinks!
				so i might just as well remove the 2nd set
				 result na lang would be equals 100% of daily rate
				 
				 sample 2 
				 plus 30% of 100% of hourly rate...
				 pwede ra gud ni na equals 130% of hourly rate na...
				 
				 kung gusto nila na plus 30% of 200% of daily rate
				 they should just pud equals 260% of daily rate... 
				 or plus 160% of daily rate
			-->
		<!--
		<input name="RW_W_1ST_RU2" type="text" size="4" maxlength="4" value="<%=strTemp%>"   
		onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RW_W_1ST_RU2')" 
		onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RW_W_1ST_RU2')" class="textbox"> 
        <select name="RW_W_1ST_RU2_PERCENT">
          <option value="0">Percentage</option>
          <%//if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(12);
	  				//else strTemp = WI.fillTextValue("RW_W_1ST_RU2_PERCENT");  
	  	
						//if (strTemp.compareTo("1")  == 0){%>
          <option value="1" selected>Specific Amount</option>
          <%//}else{%>
          <option value="1">Specific Amount</option>
          <%//}%>
        </select>
		-->
		<input name="RW_W_1ST_RU2" type="hidden" value="100"> 
		<input name="RW_W_1ST_RU2_PERCENT" type="hidden" value="0"> 	
					
				<select name="RW_W_1ST_RU2_PERCENT_UNIT" >
          <option value="0">Hourly Rate</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(13);
	  else strTemp = WI.fillTextValue("RW_W_1ST_RU2_PERCENT_UNIT");  
			if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Per Day Rate</option>
          <%}else{%>
          <option value="1">Per Day Rate</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25"><div align="right">b.)&nbsp;&nbsp;&nbsp;</div></td>
      <td>Rate/Unit (Excess)</td>
      <td height="25"><strong> </strong> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong> 
        <select name="RW_W_EX_RU">
          <option value="0">Equal</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(14);
	  else strTemp = WI.fillTextValue("RW_W_EX_RU");  
	  
	  		if (strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Plus</option>
          <%}else{%>
          <option value="1" >Plus</option>
          <%}%>
        </select>
        <% if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
	  else strTemp = WI.fillTextValue("RW_W_EX_RU_VAL"); %>
        <input name="RW_W_EX_RU_VAL" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RW_W_EX_RU_VAL')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RW_W_EX_RU_VAL')" value="<%=strTemp%>" size="6" maxlength="6">
        </strong> 
        <select name="RW_W_EX_RU_PERCENT" >
          <option value="0">Percentage</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(16);
	  else strTemp = WI.fillTextValue("RW_W_EX_RU_PERCENT"); 
	  	
			if(strTemp.compareTo("1") == 0){
		%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%} %>
        </select>
        of 
        <% 
						//if (vEditInfo != null)  
						//	strTemp = WI.getStrValue((String)vEditInfo.elementAt(17));
					  //else 
						//	strTemp = WI.fillTextValue("RW_W_EX_RU2");  
					%>
			  <!--
          <input name="RW_W_EX_RU2" type="text" size="4" maxlength="4" value="<%//=strTemp%>"   
						onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RW_W_EX_RU2')" 
						onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RW_W_EX_RU2')" class="textbox">
          <select name="RW_W_EX_RU2_PERCENT">
            <option value="0">Percentage</option>
            <%// if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(18);
							//  else strTemp = WI.fillTextValue("RW_W_EX_RU2_PERCENT");  
	  				//if (strTemp.compareTo("1")  == 0){%>
            <option value="1" selected>Specific Amount</option>
            <%//}else{%>
            <option value="1">Specific Amount</option>
            <%//}%>
          </select>
					-->
				<input type="hidden" name="RW_W_EX_RU2" value="100">
				<input type="hidden" name="RW_W_EX_RU2_PERCENT" value="0">
					
        <select name="RW_W_EX_RU2_PERCENT_UNIT" >
          <option value="0">Hourly Rate</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(19);
	  else strTemp = WI.fillTextValue("RW_W_EX_RU2_PERCENT_UNIT");  
	  		if (strTemp.compareTo("1")  == 0){%>
          <option value="1" selected>Per Day Rate</option>
          <%}else{%>
          <option value="1">Per Day Rate</option>
          <%}%>
        </select>      </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" valign="bottom"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" valign="bottom"><strong>Employee's rest day</strong>      </td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><u>If Unworked : </u></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="36" height="25">&nbsp;</td>
      <td width="145">Rate/Unit</td>
      <td height="25"><strong> </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <select name="RD_UW_RPU_UNIT" >
          <option value="0">Equal</option>
          <% if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(20);
	  else strTemp = WI.fillTextValue("RD_UW_RPU_UNIT");   
	  
	  	if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Plus</option>
          <%}else{%>
          <option value="1">Plus</option>
          <%}%>
        </select> <% if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(21));
	  else strTemp = WI.fillTextValue("RD_UW_RPU_VALUE");  %> <input name="RD_UW_RPU_VALUE" type="text" class="textbox"    onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RD_UW_RPU_VALUE')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RD_UW_RPU_VALUE')" value="<%=strTemp%>" size="6" maxlength="6"> 
        <select name="RD_UW_RPU_PERCENT" >
          <option value="0">Percentage</option>
          <% 
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(22);
		  else strTemp = WI.fillTextValue("RD_UW_RPU_PERCENT");  
		  
		  if ( strTemp.compareTo("1")  == 0){
   %>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select> <select name="RD_UW_RPU_PERCENT_UNIT">
          <option value="0">Hourly Rate</option>
          <% 
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(23);
		  else strTemp = WI.fillTextValue("RD_UW_RPU_PERCENT_UNIT");  
		  
		  if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Per Day Rate</option>
          <%}else{%>
          <option value="1" selected>Per Day Rate</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><u>If Worked : </u></td>
      <td height="25">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25"><div align="right">a.)&nbsp;&nbsp;&nbsp;</div></td>
      <td>Rate/Unit (First)</td>
      <td height="25"><strong> </strong> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> <% 
		if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(24));
		  else strTemp = WI.fillTextValue("RD_W_1ST_VALUE");  
	%> <input name="RD_W_1ST_VALUE" type="text" size="2" maxlength="2" value="<%=strTemp%>"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RD_W_1ST_VALUE')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RD_W_1ST_VALUE')" class="textbox"> 
        <select name="RD_W_1ST_UNIT">
          <option value="0">Hours</option>
          <% 
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(25);
		  else strTemp = WI.fillTextValue("RD_W_1ST_UNIT");  
	
		if (strTemp.compareTo("1") == 0) {
	%>
          <option value="1" selected>Minutes</option>
          <%}else{%>
          <option value="1">Minutes</option>
          <%}%>
        </select>
        : </td>
      <td height="25"> <select name="RD_W_1ST_RU">
          <option value="0">Equal</option>
          <% 
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(26);
		  else strTemp = WI.fillTextValue("RD_W_1ST_RU");  
		  	
			if (strTemp.compareTo("1") == 0) {
%>
          <option value="1" selected>Plus</option>
          <%}else{%>
          <option value="1">Plus</option>
          <%}%>
        </select> <% 
		if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(27));
		  else strTemp = WI.fillTextValue("RD_W_1ST_RU_VAL");  %> <input name="RD_W_1ST_RU_VAL" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RD_W_1ST_RU_VAL')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RD_W_1ST_RU_VAL')" value="<%=strTemp%>" size="6" maxlength="6"> 
        <select name="RD_W_1ST_RU_PERCENT">
          <option value="0">Percentage</option>
          <% 
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(28);
		  else strTemp = WI.fillTextValue("RD_W_1ST_RU_PERCENT");  
		  
		  	if (strTemp.compareTo("1")  == 0) {
		%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select>
        of 
       <% 
				//if (vEditInfo != null)  
				//	strTemp = WI.getStrValue((String)vEditInfo.elementAt(29));
				//else 
				//	strTemp = WI.fillTextValue("RD_W_1ST_RU2");  
			 %> 
			 <!--
			<input name="RD_W_1ST_RU2" type="text"  size="4" maxlength="4" value="<%=strTemp%>"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RD_W_1ST_RU2')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RD_W_1ST_RU2')" class="textbox"> 
        <select name="RD_W_1ST_RU2_PERCENT">
          <option value="0">Percentage</option>
          <% 
			if (vEditInfo != null)  
				strTemp = (String)vEditInfo.elementAt(30);
		  else 
				strTemp = WI.fillTextValue("RD_W_1ST_RU2_PERCENT");  

			if (strTemp.compareTo("1") == 0) {		  
			%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select> 
				-->
				<input type="hidden" name="RD_W_1ST_RU2" value="100">
				<input type="hidden" name="RD_W_1ST_RU2_PERCENT" value="0">
				
				<select name="RD_W_1ST_RU2_PERCENT_UNIT">
          <option value="0">Hourly Rate</option>
          <% 
			if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(31);
		  else strTemp = WI.fillTextValue("RD_W_1ST_RU2_PERCENT_UNIT");  

			if (strTemp.compareTo("1") == 0) {		  
		%>
          <option value="1" selected>Per Day Rate</option>
          <%}else{%>
          <option value="1" selected>Per Day Rate</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25"><div align="right">b.)&nbsp;&nbsp;&nbsp;</div></td>
      <td><p>Rate/Unit (Excess)</p></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><select name="RD_W_EX_RU">
          <option value="0">Equal</option>
          <%
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(32);
		  else strTemp = WI.fillTextValue("RD_W_EX_RU"); 
		  
	  if (strTemp.compareTo("1") == 0) {
%>
          <option value="1" selected>Plus</option>
          <%}else{%>
          <option value="1">Plus</option>
          <%}%>
        </select>
        <%
		if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(33));
		  else strTemp = WI.fillTextValue("RD_W_EX_RU_VAL"); 
%>
        <input name="RD_W_EX_RU_VAL" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RD_W_EX_RU_VAL')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RD_W_EX_RU_VAL')" value="<%=strTemp%>" size="6" maxlength="6" >
        <select name="RD_W_EX_RU_PERCENT">
          <option value="0">Percentage</option>
          <%
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(34);
		  else strTemp = WI.fillTextValue("RD_W_EX_RU_PERCENT"); 
		  
		  if (strTemp.compareTo("1") == 0) {
%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select>
        of 
        <%
						if (vEditInfo != null)  
							strTemp = WI.getStrValue((String)vEditInfo.elementAt(35));
						else 
							strTemp = WI.fillTextValue("RD_W_EX_RU2"); 
					%>
				<!--
          <input name="RD_W_EX_RU2" type="text" size="4" maxlength="4" value="<%=strTemp%>"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('dtr_op','RD_W_EX_RU2')" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','RD_W_EX_RU2')" class="textbox">
          <select name="RD_W_EX_RU2_PERCENT" >
            <option value="0">Percentage</option>
            <%
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(36);
		  else strTemp = WI.fillTextValue("RD_W_EX_RU2_PERCENT"); 

		  if (strTemp.equals("1")){%>
            <option value="1" selected>Specific Amount</option>
            <%}else{%>
            <option value="1">Specific Amount</option>
            <%}%>
          </select>
					-->
				<input type="hidden" name="RD_W_EX_RU2" value="100">
				<input type="hidden" name="RD_W_EX_RU2_PERCENT" value="0">
					
        <select name="RD_W_EX_RU2_PERCENT_UNIT">
          <option value="0">Hourly Rate</option>
          <%
		if (vEditInfo != null)  strTemp = (String)vEditInfo.elementAt(37);
		  else strTemp = WI.fillTextValue("RD_W_EX_RU2_PERCENT_UNIT"); 

		  if (strTemp.equals("1")){%>
          <option value="1" selected>Per Day Rate</option>
          <%}else{%>
          <option value="1">Per Day Rate</option>
          <%}%>
        </select>      </td>
    </tr>
    <tr> 
      <td height="43" colspan="3" align="center"> 
        <% if(vEditInfo != null) {%>
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a><font size="1">click 
          to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a> 
        <font size="1">click to cancel </font> 
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1">click 
          to add</font> 
        <%}%></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST 
      OF HOLIDAY TYPES </strong></td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="thinborder"><strong>HOLIDAY TYPE</strong></td>
      <td width="28%" height="20" align="center" class="thinborder"><strong>REGULAR 
      WORKDAY RATE</strong></td>
      <td width="28%" align="center" class="thinborder"><strong>REST DAY 
      RATE</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>GROUP NAME</strong></td>
      <td colspan="2" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
    <% 	
		String strNoWork = null;
		String strWorkFirst = null;
		String strWorkExcess = null;
		
		String[] astrRPU = {" &nbsp; ", "PLUS"};
		String[] astrPERCENT = {"%", " &nbsp;(AMOUNT)"};
		String[] astrRATE = {"HOURLY RATE", "DAILY RATE"};
		String[] astrHM = {"hr(s)", "min(s)"};
 	for (int i  = 0 ; i < vRetResult.size(); i+=45) {
		// 2 =>RPU , 3->VALUE , 4 ->PERCENT ,  5 -> UNIT
		
		strNoWork = WI.getStrValue((String)vRetResult.elementAt(i+3)
															, astrRPU[Integer.parseInt((String)vRetResult.elementAt(i+2))] + " " 
															, astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+4))] + 
																" of " + astrRATE[Integer.parseInt((String)vRetResult.elementAt(i+5))]
															,"") ;
	// doomed!
	
	// 8->RPU,9->VALUE,10->PERCENT,11->VALUE,12->PERCENT,13->RATE

	strWorkFirst = WI.getStrValue((String)vRetResult.elementAt(i+6),
								"<br> <font color=\"#FF0000\"> First ",
								" " + astrHM[Integer.parseInt((String)vRetResult.elementAt(i+7))] + " </font>:",
								"");
	
	if (strWorkFirst.length() > 0){
		strWorkFirst += WI.getStrValue((String)vRetResult.elementAt(i+9),
										astrRPU[Integer.parseInt((String)vRetResult.elementAt(i+8))] + " ",
										 astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+10))],
										"");
										
		// hide 2011-09-07   - harvey
		// strWorkFirst += " of " + WI.getStrValue((String)vRetResult.elementAt(i+11),"",astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+12))],"");
		
		strWorkFirst += astrRATE[Integer.parseInt((String)vRetResult.elementAt(i+13))] + ";";
	}
	
	strWorkExcess = "";

	// 14->RPU,15->VALUE,16->PERCENT,17->VALUE,18->PERCENT,19->RATE
	if (strWorkFirst.length() > 0 && (String)vRetResult.elementAt(i+15) != null){
		strWorkExcess = " <font color=\"#0000FF\"> Excess " + (String)vRetResult.elementAt(i+6) + " " + 
						astrHM[Integer.parseInt((String)vRetResult.elementAt(i+7))] + " </font>:"; // write excess of 8 hours
		
		strWorkExcess += WI.getStrValue((String)vRetResult.elementAt(i+15),
										astrRPU[Integer.parseInt((String)vRetResult.elementAt(i+14))] + " ",
										astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+18))],
										""); // add 
										
		// hide 2011-09-07   - harvey
		//strWorkExcess += WI.getStrValue((String)vRetResult.elementAt(i+17), " of ",
		//								 astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+18))],"");
		
		strWorkExcess += " of " +astrRATE[Integer.parseInt((String)vRetResult.elementAt(i+19))];
	}
%>
    <tr>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td valign="top" class="thinborder"><strong>UNWORKED:</strong> <%=strNoWork%><br>
        <strong><br>
        WORKED:</strong> <%=strWorkFirst+ " <br>" +strWorkExcess%></td>
      <%
		// 2 (20) =>RPU , (21) 3->VALUE , (22) 4 ->PERCENT ,  (23) 5 -> UNIT
		
		strNoWork = WI.getStrValue((String)vRetResult.elementAt(i+21)
															, astrRPU[Integer.parseInt((String)vRetResult.elementAt(i+20))] + " "  
															, astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+22))] + 
																" of " + astrRATE[Integer.parseInt((String)vRetResult.elementAt(i+23))]
															, "") ;	  
	  
	strWorkFirst = WI.getStrValue((String)vRetResult.elementAt(i+24),
								"<br> <font color=\"#FF0000\"> First ",
								" " + astrHM[Integer.parseInt((String)vRetResult.elementAt(i+25))] + " </font>:",
								"");

	// (8)26->RPU,(9)27->VALUE,(10)28->PERCENT,(11)29->VALUE,(12)30->PERCENT,(13)31->RATE
	
	if (strWorkFirst.length() > 0){
		strWorkFirst += WI.getStrValue((String)vRetResult.elementAt(i+27),
										astrRPU[Integer.parseInt((String)vRetResult.elementAt(i+26))] + " ",
										 astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+28))],
										"");
										
		// hide 2011-09-07    harvey
		//strWorkFirst += WI.getStrValue((String)vRetResult.elementAt(i+29)," of ",
		//												astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+30))],"");
		
		strWorkFirst += " of " + astrRATE[Integer.parseInt((String)vRetResult.elementAt(i+31))] + ";";
	}
	
	strWorkExcess = "";

	// (14)32->RPU,(15)33->VALUE,(16)34->PERCENT,(17)35->VALUE,(18)36->PERCENT,(19)37->RATE
	if (strWorkFirst.length() > 0 && (String)vRetResult.elementAt(i+33) != null){
		strWorkExcess = "<font color=\"#0000FF\"><br> Excess " + (String)vRetResult.elementAt(i+24) + " " + 
						astrHM[Integer.parseInt((String)vRetResult.elementAt(i+25))] + " </font>:"; // write excess of 8 hours
		
		strWorkExcess += WI.getStrValue((String)vRetResult.elementAt(i+33),
										astrRPU[Integer.parseInt((String)vRetResult.elementAt(i+32))] + " ",
										astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+34))],
										""); // add 
		// hide 2011-09-07   - harvey				
		//strWorkExcess += WI.getStrValue((String)vRetResult.elementAt(i+35), " of ",
		//								 astrPERCENT[Integer.parseInt((String)vRetResult.elementAt(i+36))], "");
		
		strWorkExcess += " of " +astrRATE[Integer.parseInt((String)vRetResult.elementAt(i+37))];
	}
%>
      <td valign="top" class="thinborder"><strong>UNWORKED:</strong> <%=strNoWork%><br>
	  <strong><br> WORKED:</strong> <%=strWorkFirst+ " " +strWorkExcess%></td>
      <td valign="top" class="thinborder"><%=(String)vRetResult.elementAt(i+41)%></td>
      <td width="7%" class="thinborder"> <% if (iAccessLevel > 1) {%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%> &nbsp; <%}%> </td>
      <td width="8%" class="thinborder"> <% if (iAccessLevel ==2) {%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%> &nbsp; <%}%> </td>
    </tr>
    <%} // end for loop %>
  </table>
<%} // if vRetResult != null%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="group_index" value="<%=WI.fillTextValue("group_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>


