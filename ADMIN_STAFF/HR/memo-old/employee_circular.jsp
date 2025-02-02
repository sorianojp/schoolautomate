<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	
	String strSchCode = 
			WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
			
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
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
a{
	text-decoration:none;
}

</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript">
	function ReloadPage(){
		this.SubmitOnce("form_");
	}
	
	function ReadInfo(strMemoSentIndex){
		document.form_.memo_sent_index.value=strMemoSentIndex;
		this.SubmitOnce("form_");
	}
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
//		alert ("helloe world");
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}

	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	function UpdateNameFormat(strName) {
		//do nothing.
	}	
	
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-MEMO Management-Employee Circular",
								"employee_circular.jsp");

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;

if (bolMyHome){
	iAccessLevel = 1;
}else{
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
									(String)request.getSession(false).getAttribute("userId"),
									"HR Management","MEMO MANAGEMENT",request.getRemoteAddr(),
									"employee_circular.jsp");
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home", "../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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

Vector vRetResult = null;
Vector vRetDetail = null;

hr.HRMemoManagement  mt = new hr.HRMemoManagement();
strTemp = WI.fillTextValue("emp_id");

if (bolMyHome){
	strTemp = (String)request.getSession(false).getAttribute("userId");
}


if (strTemp.length() > 0) {
	vRetResult = mt.operateOnEmpMemo(dbOP, request,4);
	
	if (vRetResult == null){
		strErrMsg = mt.getErrMsg();
	}
	
	if (WI.fillTextValue("memo_sent_index").length() > 0){
		vRetDetail = mt.operateOnEmpMemo(dbOP, request,3);
		if (vRetDetail == null)
			strErrMsg = mt.getErrMsg();
	}
}
%>
<body bgcolor="#663300"  class="bgDynamic">
<form action="./employee_circular.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: SET MANDATORY TRAINING FOR PERSONNEL ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>


  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="15%" height="25">EMPLOYEE ID </td>
 	  <td width="18%" height="25">
<% if (!bolMyHome){ %> 
	  	<input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AjaxMapName(1);" value="<%=strTemp%>"
		onBlur="style.backgroundColor='white'" size="16" >
<%}else{%> 
	<font size="3" color="#FF000"><strong>
			<%=(String)request.getSession(false).getAttribute("userId")%> </strong> </font>
<%}%>	  </td>
      <td width="9%">
	 <% if (!bolMyHome) {%> 
	  <a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a>
	  <%}%> 
	  
	  </td>
      <td width="54%">&nbsp;
      <label id="coa_info"></label></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<!--
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="17%" height="30" valign="bottom">MEMO  NAME </td>
      <td width="79%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="2"><strong>
        <select name="memo_index" onChange="UpdateMemoIndex()" >
          <option value="">Select Memo</option>
          <%//=dbOP.loadCombo("memo_index","memo_name",
	  		//		" FROM hr_memo_details where is_valid = 1 and is_del = 0 " + 
			//		WI.getStrValue(request.getParameter("memo_type_index"),
			//		"and  memo_type_index = ","","") + 
			//		" order by memo_name",WI.fillTextValue("memo_index"),false)%>
        </select>
      </strong></td>
    </tr>
<%// if (WI.fillTextValue("memo_index").length() > 0) {%> 
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="2">Date of Memo : 
        <select name="memo_sent_index" onChange="ReloadPage()">
 	    <option value="">Select Date of Memo</option>
		<%// for (int i = 0; i < vDates.size();i+=2){
		//	if (WI.fillTextValue("memo_sent_index").equals((String)vDates.elementAt(i))){
		%> 
		<option value="<%//=(String)vDates.elementAt(i)%>" selected>
							<%//=(String)vDates.elementAt(i+1)%></option>
		<%//}else{%> 
		<option value="<%//=(String)vDates.elementAt(i)%>">
							<%//=(String)vDates.elementAt(i+1)%></option>		
		<%//} // end if else
		//} // end for loop%> 		
		</select> 
		</td>
    </tr>
<%//}%> 
  </table>
-->
<% if (WI.fillTextValue("memo_sent_index").length() > 0) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <% if (vRetDetail !=null && vRetDetail.size() > 0) {%>
    <tr>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="5%" height="23">&nbsp;</td>
      <td width="88%" class="thinborderALL" style="padding:5x"><%=(String)vRetDetail.elementAt(0)%></td>
      <td width="7%">&nbsp;</td>
    </tr>
    <tr>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
	<%}%>
  </table>
<%}
if (vRetResult != null) { %> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
      <td height="25" colspan="3" align="center" bgcolor="#F4F2F3" class="thinborder"><strong>LIST OF MEMO ADDRESSED TO EMPLOYEE</strong></td>
    </tr>
<% for(int i = 1; i < vRetResult.size(); i+=4){%> 
    <tr>
      <td width="6%" height="20" class="thinborder">&nbsp;</td>
      <td width="60%" class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(i) + " :: " + 
	  								(String)vRetResult.elementAt(i+1)%></td>
      <td width="34%" class="thinborder">&nbsp;
	  <a href="javascript:ReadInfo('<%=(String)vRetResult.elementAt(i+3)%>')">
	  	  	<%=(String)vRetResult.elementAt(i+2)%>	  </a>   	  </td>
    </tr>
<%}%> 
  </table>
<%}%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="memo_sent_index" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

