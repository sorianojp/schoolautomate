<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime,eDTR.eDTRUtil"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
	function ReloadPage(){
		document.form_.print_page.value="";
		this.SubmitOnce("form_");
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		this.SubmitOnce("form_");
	}
	
	function CloseWindow(){
		self.close();
	}
	
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./set_overtime_param_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Staff-eDaily Time Record-OVERTIME MANAGEMENT-Set Overtime Parameters","set_overtime_param.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(),
														"set_overtime_param.jsp");
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

OverTime ot = new OverTime ();
Vector vRetResult = null;

vRetResult = ot.operateOnOTParameter(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = ot.getErrMsg();
}

%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./set_overtime_param.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SET OVERTIME PARAMETERS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;<a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a>&nbsp; 
      &nbsp;<%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'><strong>","</strong></font>","")%></td>
    </tr>
  </table>
  <% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="60%" valign="bottom">&nbsp;</td>
      <td width="40%" height="10" colspan="2" valign="bottom"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print table</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center">LIST OF 
          EMPLOYEES WITH OVERTIME PARAMETERS</div></td>
    </tr>
    <tr> 
      <td width="12%" height="26" class="thinborder"><div align="center"><strong>EMPLOYEE 
          ID </strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>EMPLOYEE NAME</strong></div></td>
      <td class="thinborder"><div align="center"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/OFFICE</strong></div></td>
      <td class="thinborder"><div align="center"><strong>TIME</strong></div></td>
      <td class="thinborder"><div align="center"><strong>EFFECTIVITY DATE</strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=13) {%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+12)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
      <td width="25%" class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
      <td width="16%" class="thinborder"><%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+4),
	  					(String)vRetResult.elementAt(i+5),
	  					(String)vRetResult.elementAt(i+6)) + " - " + 
						eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
	  					(String)vRetResult.elementAt(i+8),
	  					(String)vRetResult.elementAt(i+9))%></td>
      <td width="24%" class="thinborder"><%=((String)vRetResult.elementAt(i+2)) + " - " + ((String)vRetResult.elementAt(i+3))%></td>
    </tr>
    <%} // end for loop%>
  </table>
 <%} // vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page">
<input type="hidden" name="show_all" value="<%=WI.fillTextValue("show_all")%>"> 
</form>
</body>
</html>
