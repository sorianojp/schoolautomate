<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this entry.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance -non-credit subject","curriculum_subject_enrichment.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_subject_enrichment.jsp");
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


CurriculumSM SM = new CurriculumSM();
Vector vRetResult = new Vector();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	//add it here and give a message.
	if(SM.operateOnNonCreditSubject(dbOP,request,Integer.parseInt(strTemp)) != null)
		strErrMsg = "Operation Successful.";
	else
		strErrMsg = SM.getErrMsg();
}

//get all levels created.
vRetResult = SM.operateOnNonCreditSubject(dbOP,request,4);
if(vRetResult == null && strErrMsg == null) {
	strErrMsg = SM.getErrMsg();
}


%>

<form name="form_" method="post" action="./curriculum_subject_enrichment.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          NO CREDIT SUBJECT LISTING ::::</strong></font></div></td>
    </tr>
	</table>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>SUBJECT LIST : </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  	<select name="sub_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; color:#0000FF;">
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as scode",
		  	" from subject where IS_DEL=0 and not exists (select * from SUBJECT_ENRICHMENT where SUBJECT_ENRICHMENT.sub_index = subject.sub_index) order by scode asc", WI.fillTextValue("sub_index"), false)%> 
		</select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Credit Lec Unit :
        <input name="credit_lec" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("credit_lec")%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"> 
      Credit Lab Unit : 
      <input name="credit_lab" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("credit_lab")%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">&nbsp;</td>
      <td width="83%" height="25"> 
	  <%if(iAccessLevel > 1){%> 
	  	<a href="javascript:PageAction('','1');"><img name="addImage" src="../../../images/add.gif" border="0"></a> 
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to save entry</font>
	  <%}%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">&nbsp;</td>
    </tr>
    <%if(strErrMsg != null){%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>
<table width=100% border=0 bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">

    <tr bgcolor="#B9B292">
      <td height="25"class="thinborderTOPLEFTRIGHT"><div align="center">LIST OF NON-CREDIT SUBJECTS </div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() >0) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold"> 
      <td width="15%" align="center" height="25" class="thinborder">Subject Code </td>
      <td width="40%" align="center" class="thinborder">Description</td>
      <td width="10%" align="center" class="thinborder">Lec Credit </td>
      <td width="10%" align="center" class="thinborder">Lab Credit </td>
      <td width="15%" align="center" class="thinborder">No Of Entry in Curriculum Having wrong Units set </td>
      <td width="10%" align="center" class="thinborder">Delete</td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); i += 6) {
strTemp = (String)vRetResult.elementAt(i+5);%>
    <tr> 
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td align="center" class="thinborder"><%if(strTemp == null || strTemp.equals("0")) {%> All Ok<%}else{%> 
	  	<a href="javascript:PageAction('<%=vRetResult.elementAt(i)%>','5');"><%=strTemp%> (Delete)</a>
	  <%}%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2){%> <a href="javascript:PageAction('<%=vRetResult.elementAt(i)%>','0');"><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
    </tr>
<%}//end of loop %>
  </table>

<%}//end of displaying %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<!-- all hidden fields go here -->
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
