<html>
<head>
<title>SchoolBliz Products</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css"></link>
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
	document.form_.print_.src = "../../images/blank.gif";
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.user_id.value;
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_id.value = strID;
	//document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>"+strName+"</font>";
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector, search.FSProduct" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	
	int iAccessLevel = 0;
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	
	

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	Vector vEmployee = null;
	Vector vStudent  = null;

	FSProduct  fsProd = new FSProduct();
	strTemp = WI.fillTextValue("page_action");//System.out.println(strTemp);

	if(strTemp.length() > 0) {
		if(fsProd.operateOnUserWithErrorInFS(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = fsProd.getErrMsg();
		else
			strErrMsg = "Operation Successful";	
	}
	vRetResult = fsProd.operateOnUserWithErrorInFS(dbOP,request,4);
	if(vRetResult == null)
		strErrMsg = fsProd.getErrMsg();
	else {
		vEmployee = (Vector)vRetResult.remove(0);
		vStudent = (Vector)vRetResult.remove(0);
	}
%>

<body>
<form action="exclude_user_fs.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this)">
  <table width="100%" border="0" cellspacing="0" cellpadding="1" id="myADTable1">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong><font size="2"><u>
	  Manage Users Donot Need for Finger Print Verification</u></font></strong></div></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td height="25" colspan="2"><font size="2" color="#FF0000" ><strong><%=WI.getStrValue(strErrMsg)%></strong></font>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="17%">ID Number </td>
      <td width="80%" height="25"> 
	  <input type="text" name="user_id" class="textbox" onKeyUp="AjaxMapName();"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	     
	  <input type="submit" value="Save ID" name="submit_page" onClick="document.form_.page_action.value='1';">    
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25"><label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2"><div align="center"><strong><font size="2"><u>List of Users do not require Finger Verification</u></font></strong></div></td>
    </tr>
    <tr align="center" valign="top">
	  <td><%if(vEmployee != null && vEmployee.size() > 0) {%>
		  <table width="98%" cellpadding="0" cellspacing="0" class="thinborder">
			  <tr align="center" style="font-weight:bold" bgcolor="#CCCCCC">
			    <td height="22" class="thinborder">Employee ID </td>
			    <td class="thinborder">Name</td>
			    <td class="thinborder">Delete</td> 
			  </tr>
			  <%while(vEmployee.size() > 0) {%>
				<tr>
				  <td height="22" class="thinborder"><%=vEmployee.remove(1)%></td>
				  <td class="thinborder"><%=vEmployee.remove(1)%></td>
				  <td class="thinborder" align="center"><input type="button" name="_1" value="Delete" onClick="document.form_.info_index.value='<%=vEmployee.remove(0)%>'; document.form_.page_action.value='0';document.form_.submit()"></td>
		    	</tr><%}%>
		  </table><%}%>		
	  </td>
		<td><%if(vStudent != null && vStudent.size() > 0) {%>
			<table width="98%" cellpadding="0" cellspacing="0" class="thinborder">
				<tr align="center" style="font-weight:bold" bgcolor="#CCCCCC">
				  <td height="22" class="thinborder">Student ID </td>
				  <td class="thinborder">Name</td>
				  <td class="thinborder">Delete</td>
				</tr>
			  <%while(vStudent.size() > 0) {%>
				<tr>
				  <td height="22" class="thinborder"><%=vStudent.remove(1)%></td>
				  <td class="thinborder"><%=vStudent.remove(1)%></td>
				  <td class="thinborder" align="center"><input type="button" name="_1" value="Delete" onClick="document.form_.info_index.value='<%=vStudent.remove(0)%>'; document.form_.page_action.value='0'; document.form_.submit()"></td>
		    	</tr><%}%>
			</table><%}%>		
	  </td>
    </tr>
  </table>
<%}%>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>