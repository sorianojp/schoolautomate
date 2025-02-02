<%@ page language="java" import="utility.*, inventory.InventoryMaintenance, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Gate Pass Details Management Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../../jscript/date-picker.js" ></script>
<script language="javascript"  src="../../../../Ajax/ajax.js"></script>
<script>
function PageAction(strAction,strInfoIndex)
{		
	if(strAction == "0"){
		if(!confirm("Do want to delete this entry?"))
			return;
	}

	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value= strAction;
	document.form_.prepareToEdit.value = "";
	this.ReloadPage();
	
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;		
	document.form_.page_action.value= "";
	document.form_.prepareToEdit.value = "1";
	this.ReloadPage();
}

function ReloadPage(){
	document.form_.submit();
}


function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadParentWnd() {

		window.opener.document.form_.submit();

		window.opener.focus();
	
}



</script>
</head>

<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;

	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try
	{
	 	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","gate_pass_details.jsp");								

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	
	

	
Vector vRetResult = null;
Vector vEditInfo = null;

InventoryMaintenance invMaintenance = new InventoryMaintenance();
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

String strGatePassNo = WI.fillTextValue("gate_pass_no");	


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	vRetResult = invMaintenance.operateOnGatePassDetails(dbOP, request, Integer.parseInt(strTemp), strGatePassNo);
	if( vRetResult == null )
		strErrMsg = invMaintenance.getErrMsg();
	else{		
		if(strTemp.equals("1"))
			strErrMsg = "Gate Pass details successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Gate Pass details successfully updated.";
		if(strTemp.equals("0"))
			strErrMsg = "Gate Pass details successfully deleted.";
	}
	
	strPrepareToEdit = "0";
}

if(strPrepareToEdit.equals("1")){
	vEditInfo = invMaintenance.operateOnGatePassDetails(dbOP, request, 3, strGatePassNo);
	if(vEditInfo == null)	
		strErrMsg  = invMaintenance.getErrMsg();
}

vRetResult = invMaintenance.operateOnGatePassDetails(dbOP, request, 4, strGatePassNo);

%>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form name="form_" action="gate_pass_details.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GATE PASS DETAILS MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="12%"><strong>Gate Pass #</strong></td>
      <td ><strong><%=strGatePassNo%></strong></td>
      </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#C78D8D"> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><strong><font color="#FFFFFF">GATE PASS INFORMATION</font></strong></td>
    </tr>
    <tr> 
      <td colspan="5" height="10">&nbsp;</td>
    </tr>
	 <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Quantity :</td>
		 <%
		 	strTemp= WI.fillTextValue("quantity");
		 	if(vEditInfo != null  && vEditInfo.size() > 0) 
				strTemp = (String)vEditInfo.elementAt(2);
		%>
      <td height="30" colspan="2" valign="middle">
			<input type="text" name="quantity" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','quantity');style.backgroundColor='white';" 
					onkeyup="AllowOnlyFloat('form_','quantity')" size="3" maxlength="5" value="<%=strTemp%>"/>
		</td>
    </tr>
	 <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">Unit :</td>		
      <td height="30" colspan="2" valign="middle">
			<select name="unit_index">
          <%
			 	strTemp= WI.fillTextValue("unit_index");
			 	if(vEditInfo != null  && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(6);	
			%>
          <option value="">Select Selling Unit</option>
          <%=dbOP.loadCombo("UNIT_INDEX","UNIT_NAME", " from PUR_PRELOAD_UNIT order by UNIT_NAME",strTemp,false)%>
			 </select>
			 
			 <a href='javascript:viewList("pur_preload_unit","UNIT_INDEX","UNIT_NAME","UNIT NAME", "INV_GATE_PASS_DTLS", 
			 	"unit_index"," and is_valid = 1","","unit_index");'> 
        <u><font color="#FF6633"><b><img src="../../../../images/update.gif" border="0" align="absmiddle"></b></font></u></a>
		</td>
    </tr>
	 
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td colspan="2" valign="top">Description</td>
		<%
		strTemp = WI.fillTextValue("description");
		if(vEditInfo != null  && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(4);
		%>
      <td width="81%" height="30" colspan="2">
		<textarea name="description" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
		</td>
    </tr>
	  <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td colspan="2" valign="top">Purpose</td>
		<%
		strTemp = WI.fillTextValue("purpose");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		%>
      <td height="30" colspan="2">
		<textarea name="purpose" cols="45" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
		</td>
    </tr>
    
	 
	 
    
    
    
    <tr> 
      <td height="48">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td height="48" colspan="2" valign="middle"><font size="1"> 
		<%
		if(strPrepareToEdit.equals("0")){
		%>      
			<a href="javascript:PageAction('1','');"> <img src="../../../../images/save.gif" border="0"></a> 
        Click to save information 
		<%}else{%>
        
		  <a href="javascript:PageAction('2','');"> <img src="../../../../images/edit.gif" border="0"></a> 
        Click to update information 
      <%}%> 
		
		 <a href="javascript:Cancel();"> <img src="../../../../images/cancel.gif" border="0"></a> 
        Click to cancel operation 
		
        </font></td>
    </tr>
  </table>  
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	   <td align="center" height="22">&nbsp;</td>
	   </tr>
	<tr><td align="center" height="22"><strong>LIST OF GATE PASS DETAILS FOR <%=strGatePassNo%></strong></td></tr>
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="13%" height="20" align="center" class="thinborder">QUANTITY</td>
		<td width="12%" align="center" class="thinborder">UNIT</td>
		<td width="33%" align="center" class="thinborder">DESCRIPTION</td>
		<td width="30%" align="center" class="thinborder">PURPOSE</td>
	   <td width="12%" align="center" class="thinborder">OPTION</td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=16){
	%>
	<tr>
		<td class="thinborder" align="center" height="18"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), true)%></td>
		<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
	   <td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border="0"></a>
			&nbsp;
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	<%}%>
</table>
<%}%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input name="info_index" type="hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="page_action">
	 <input type="hidden" name="proceed" value="<%=WI.fillTextValue("proceed")%>">
	 <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	 <input type="hidden" name="gate_pass_no" value="<%=strGatePassNo%>">
   	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>