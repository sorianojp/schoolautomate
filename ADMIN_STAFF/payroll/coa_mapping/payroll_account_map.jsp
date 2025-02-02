<%@ page language="java" import="utility.*,payroll.PRCOAMapping,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.style1 {
	font-size: 9px;
	font-weight: bold;
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function MapItems(){	
	document.form_.map_items.value= "1";
	document.form_.save.disabled = true;
	document.form_.submit();
}

function ReloadPage() {
	document.form_.submit();
}
function CancelRecord(){
	location = "./payroll_account_map.jsp";
}
 
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function goToMain(){
	location = "./coa_main.jsp";
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-COA Config-Account Mapping","payroll_account_map.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"payroll_account_map.jsp");
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

	PRCOAMapping prCOA = new PRCOAMapping();
	Vector vRetResult = null;
	String strCodeIndex  = null;
	String strType = null;
	String strFieldType = null;
	int i = 0;

	if(WI.fillTextValue("map_items").length() > 0){
		if(prCOA.operateOnPayrollMapping(dbOP, request, 1) == null)
			strErrMsg =  prCOA.getErrMsg();
	}
	
	vRetResult  = prCOA.operateOnPayrollMapping(dbOP, request, 4);

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="payroll_account_map.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL ACCOUNT MAPPING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><a href="javascript:goToMain();">MAIN</a>&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
	  
    <tr>
      <td height="25">&nbsp;</td>
      <td>Grouping</td>
      <td width="75%"><font size="1">
        <select name="item_type" onChange="document.form_.dType.value='';ReloadPage();">
          <option value="0">EARNINGS</option>
          <%
					strFieldType = WI.getStrValue(WI.fillTextValue("item_type"),"0");
					if(strFieldType.equals("1")) {%>
          <option value="1" selected>DEDUCTIONS</option>
          <%}else{%>
          <option value="1">DEDUCTIONS</option>
          <%}%>
        </select>
      </font></td>
    </tr>
		<%
		strType = WI.fillTextValue("dType");
		%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="21%">Item Source </td>
      <td><font size="1">
        <select name="dType" onChange="ReloadPage();">
					<option value="">Select field</option>
				<%if(strFieldType.equals("1")){%>          
					<%if(strType.compareTo("1") == 0) {%>
          <option value="1" selected>Miscellaneous Deductions</option>
          <%}else{%>
					<option value="1">Miscellaneous Deductions</option>
          <%}%>
					<%if(strType.compareTo("2") == 0) {%>
          <option value="2" selected>Loans</option>
          <%}else{%>
          <option value="2">Loans</option>
          <%}%>
					<%if(strType.compareTo("3") == 0){%>
          <option value="3" selected>Contribution</option>
          <%}else{%>
          <option value="3">Contribution</option>
          <%}%>
        <%} else if(strFieldType.equals("0")) {%>
					<%if(strType.compareTo("4") == 0){%>
          <option value="4" selected>Misc. Earning</option>
					<%}else{%>
					<option value="4">Misc. Earning</option>
					<%}%>
          <%if(strType.compareTo("5") == 0){%>
          <option value="5" selected>Allowances</option>
          <%}else{%>
          <option value="5">Allowances</option>
					<%}%>
          <%if(strType.compareTo("6") == 0){%>
          <option value="6" selected>Incentives</option>
          <%}else{%>
          <option value="6">Incentives</option>
					<%}%>
					
          <%if(strType.compareTo("7") == 0){%>
          <option value="7" selected>Additional Pay/ Bonuses</option>
          <%}else{%>
          <option value="7">Additional Pay/ Bonuses</option>
					<%}%>					
 			  <%}%>
        </select>
      </font></td>
    </tr>
    
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="24" colspan="4" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">LIST OF 
          ITEM MAPPINGS </font></strong></td>
    </tr>
    <tr>
      <td width="5%" align="center" class="thinborder">&nbsp;</td> 
      <td width="51%" height="25" align="center" class="thinborder"><strong>Item Type </strong></td>
      <td width="35%" align="center" class="thinborder style1"> Mapping Header </td>
			<%
				strTemp = WI.fillTextValue("selAllSave");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";			
			%>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" <%=strTemp%>>
      </font></td>
    </tr>
		<%
		int iCount = 1;
		for(i = 0; i < vRetResult.size();i+=11, iCount++){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=iCount%></td> 
			<input type="hidden" name="ref_index_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+2),"(", ")","");
			%>
			<input type="hidden" name="item_name_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <%
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp, "not mapped");
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
      <%
				strTemp = WI.fillTextValue("save_"+iCount);
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center">
			<input type="checkbox" name="save_<%=iCount%>" value="1" <%=strTemp%> tabindex="-1"></td>
    </tr>
		<%}%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	<%}%>
	<%if(strType.length() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
       <td height="19" colspan="2"></td>
     </tr>
     <tr>
       <td width="4%">&nbsp;</td>
       <%
				 strTemp = WI.fillTextValue("coa_map_main_index");			 
			 %>
			 <td width="96%" height="30">Mapping Header
			 <select name="coa_map_main_index">
         <option value="">Select mapping header</option>
         <%=dbOP.loadCombo("coa_map_main_index","map_header_name", 
				 									 " from pr_coa_map_main order by order_no",strTemp,false)%>
       </select></td>
     </tr>
     
     <tr>
       <td>&nbsp;</td>
       <td height="25"><font size="1">
         <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:MapItems();">
Click to save entries
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
       </font></td>
     </tr>
     <tr>
       <td></td>
      <td height="16"> </td>
    </tr>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>	
<input type="hidden" name="map_items">
<input type="hidden" name="reloaded" value="<%=WI.fillTextValue("reloaded")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
