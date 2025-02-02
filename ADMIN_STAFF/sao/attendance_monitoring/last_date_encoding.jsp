<%@ page language="java" import="utility.*, enrollment.AttendanceMonitoringCDD, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">

 /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    width:350px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }


</style>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to remove this entry?"))
			return;
	}

	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value =strAction;
	document.form_.submit();
}

function ReloadPage()
{
	document.form_.info_index.value ="";
	document.form_.page_action.value ="";
	document.form_.submit();
}



function ShowHideEmpID()
{
	if(document.form_.is_for_one_faculty.checked)
		showLayer("emp_id_");
	else {
		document.form_.emp_id.value = "";
		hideLayer("emp_id_");
	}


}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.emp_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.emp_id.value = strID;
	
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}


</script>
</head>
<body bgcolor="#D2AE72">
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","last_date_encoding.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

Vector vRetResult = null;
Vector vStudDtls  = null;
Vector vCCStatus  = new Vector();
Vector vClaimedCC = new Vector();
Vector vCCNotClaimed = new Vector();
Vector vSubDropped = new Vector();

AttendanceMonitoringCDD attendanceCDD = new AttendanceMonitoringCDD();
strTemp = WI.fillTextValue("page_action");
System.out.println("test "+WI.fillTextValue("info_index"));
if(strTemp.length() > 0){
	vRetResult = attendanceCDD.operateOnLastDateEncoding(dbOP, request, Integer.parseInt(strTemp));
	if(vRetResult == null)
		strErrMsg = attendanceCDD.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry successfully removed.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry successfully recorded.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry successfully updated.";		
	}
}
	
vRetResult = attendanceCDD.operateOnLastDateEncoding(dbOP, request, 4);



String strBGColor = null;
%>
<form action="./last_date_encoding.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          SET LAST DATE OF ENCODING ::::</strong></font></div></td>
    </tr>
    <tr >
	<td height="25" colspan="4">&nbsp; &nbsp; &nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font>	</td>
	</tr>

	<tr>
		<td height="25" width="2%">&nbsp;</td>
		<td width="17%">SY/Term</td>		
		<td width="81%">			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<select name="semester">
			<%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>
			</select>
			
			&nbsp;&nbsp;
			<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
			</td>		
	</tr>
	
    <tr>
      <td height="25" width="2%"></td>
      <td width="17%">Last Date </td>
	  <%strTemp = WI.fillTextValue("emp_id");%>
      <td width="81%">
	  <input name="last_date_encode" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("last_date_encode")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.last_date_encode');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    <tr>
        <td height="25"></td>
        <td>
		<%
strTemp = WI.fillTextValue("is_for_one_faculty");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="is_for_one_faculty" value="1" <%=strTemp%> onClick="ShowHideEmpID();">
        Allow Specific Faculty
		</td>
        <td>
		<input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" id="emp_id_" onKeyUp="AjaxMapName(1);">
        (Faculty Employee ID)
		<label id="coa_info" style="position:absolute; width:400px;"></label>		
		</td>
		<script language="JavaScript">
ShowHideEmpID();
</script>    
    </tr>
    <tr>
        <td height="25"></td>
        <td>&nbsp;</td>
        <td>
		<a href="javascript:PageAction('1','')"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">click to record entry</font>
		</td>
    </tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
	</tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25"><div align="center">ATTENDANCE LAST ENCODING DATE</div></td>
    </tr>
</table>


  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      
      <td width="23%"><div align="center"><strong><font size="1">LAST ENCODING DATE </font></strong></div></td>
      <td width="27%"><div align="center"><strong><font size="1">FACULY EMP ID</font></strong></div></td>
      <td width="28%"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
    <%
for(int i =0;i< vRetResult.size(); i +=3){%>
    <tr>
      <td height="25" align="right">&nbsp;</td>      
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+2))%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+1))%></td>
      <td align="center">
        <%
	if( iAccessLevel >1){%>
        <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not Allowed to delete
        <%}%>
      </td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
