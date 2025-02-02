<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage()
{
	document.form_.showdetails.value ="0";
	document.form_.print_page.value ="0";
	document.form_.submit();
}


function ShowDetails(){
	document.form_.print_page.value = "";
	document.form_.showdetails.value = "1";
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAEducPlans,enrollment.EnrlAddDropSubject,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;



	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./list_of_stud_educ_plans_print.jsp" />
	<%	return;
	}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
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
String[] astrConvertYrLevel={"","First", "Second","Third", "Fourth", "Fifth", "Sixth"};
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
String[] astrConvertProper={"","Preparatory","Proper"};
String[] astrConvertStatus={"DISAPPROVED","APPROVED","PENDING"};
Vector vRetResult = null;
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
FAEducPlans faEP = new FAEducPlans();




	if (WI.fillTextValue("showdetails").compareTo("1") == 0){
		vRetResult = faEP.operateOnEducPlans(dbOP,request,4);
		
		if (vRetResult == null)
			strErrMsg = faEP.getErrMsg();
	}
%>

<form name="form_" action="./list_of_stud_educ_plans.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          LIST OF STUDENTS WITH EDUCATIONAL PLANS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%" height="25">School Year </td>
      <td width="35%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td width="49%" height="25"><a href="javascript:ShowDetails()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="23%" height="25">Educational Plans </td>
      <td width="23%" height="25">
	  
	  <select name="xtra_plan" id="xtra_plan" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("AI_INDEX","AFF_INST_CODE" ," from FA_AFFILIATED_INST where IS_DEL=0 ",
		   request.getParameter("xtra_plan"), false)%> 
        </select>
		</td>
      <td>Status :</td>
      <td height="25"><select name="xtra_status" id="xtra_status">
	  	   <option value=""> All</option>		   
<% if (WI.fillTextValue("xtra_status").compareTo("2") == 0 ){ %>
          <option value="2" selected>Pending</option>
<%}else{ %>s
          <option value="2" >Pending</option>
<%}if (WI.fillTextValue("xtra_status").compareTo("1") == 0 ){ %>
          <option value="1" selected>Approved</option>
<%}else{%>
          <option value="1">Approved</option>		  
<%}%>
        </select></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size()> 0){ %>
 <table width="100%" bgcolor="#FFFFFF">
     <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="41%" height="25"><div align="right"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print list</font></font></div></td>
    </tr>
 </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="10" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF STUDENTS WITH EDUCATIONAL PLANS</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="10"><b>Total Student(s) : <%=(int)(vRetResult.size()/17)%></b> <div align="right"></div></td>
    </tr>
    <tr> 
      <td width="11%" height="25"><div align="center"><strong><font size="1">STUDENT 
          ID </font></strong></div></td>
      <td width="25%"><div align="center"><strong><font size="1">STUDENT NAME</font></strong></div></td>
      <td width="33%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="16%"><div align="center"><strong>PLAN</strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="7%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
    <% for (int i= 0; i < vRetResult.size() ; i+=17) {%>
    <tr> 
      <td height="25"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+16)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+12)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+13)%><%=WI.getStrValue((String)vRetResult.elementAt(i+14),"/","","")%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td><font size="1">&nbsp;<%=astrConvertStatus[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+15)%></font></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" bgcolor="#FFFFFF">    <tr>
      <td width="10%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="center"><font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print list</font></font></div></td>
      <td width="5%" height="25" colspan="3">&nbsp;</td>
    </tr></table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="showdetails">
<input type="hidden" name="print_page">
</form>
</body>
</html>
