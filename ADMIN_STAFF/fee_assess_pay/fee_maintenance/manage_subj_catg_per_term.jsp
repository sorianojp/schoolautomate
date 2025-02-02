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
function DeleteRecord(strTargetIndex)
{
	if(!confirm('Are you sure you want to delete this record.'))
		return;
	document.form_.page_action.value = 0;
	document.form_.info_index.value = strTargetIndex;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-setup subject category per term","manage_subj_catg_per_term.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"manage_subj_catg_per_term.jsp");
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

FAFeeMaintenance feeM = new FAFeeMaintenance();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(feeM.operateOnSubjectCatgPerSYTerm(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = feeM.getErrMsg();
	else 
		strErrMsg = "Operation Successful.";		
}

Vector vRetResult = feeM.operateOnSubjectCatgPerSYTerm(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = feeM.getErrMsg();

%>
<form name="form_" action="./manage_subj_catg_per_term.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: Define Subject Category per SY-Term ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">  
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">SY-Term</td>
      <td width="89%">
	<%
	String strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom == null || strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
   <%
	strTemp = request.getParameter("sy_to");
	if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  -
	  
<%
String strSemester = WI.fillTextValue("semester");
if(request.getParameter("semester") == null) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");	

if(strSemester == null)
	strSemester = "";

if(strSemester.equals("1"))
	strTemp = " selected";
else
	strTemp = "";
%>
	  <select name="semester">
          <option value="0">Summer</option>
          <option value="1" <%=strTemp%>>1st Term</option>
<%
if(strSemester.equals("2"))
	strTemp = " selected";
else
	strTemp = "";
%>
          <option value="2" <%=strTemp%>>2nd Term</option>
<%
if(strSemester.equals("3"))
	strTemp = " selected";
else
	strTemp = "";
%>
          <option value="3" <%=strTemp%>>3rd Term</option>
        </select>
	  <input type="submit" name="122_" value="&nbsp;&nbsp;View Category Already Set&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=''">	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject</td>
      <td>
	  <select name="sub_index" style="width:600px; font-size:11px;">
	  <option></option>
  <%
strTemp = " from subject where is_del = 0 and not exists (select * from SUBJECT_CATG_PER_SEM where is_valid = 1 and s_index = sub_index and sy_fr = "+
	strSYFrom+" and (term = "+strSemester +" or term is null)) order by sub_code";
%>					
  <%=dbOP.loadCombo("sub_index","sub_code, sub_name",strTemp, WI.fillTextValue("sub_index"), false)%>
      </select>
	  </td>
    </tr>
    <tr>  
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">Category</td>
      <td width="89%">
		<select tabindex="4" name="catg_index" style="font-size:11px;">	  	
	  <option></option>
      		<%=dbOP.loadCombo("catg_index","catg_name"," from subject_catg where IS_DEL=0 and MULTIPLE_OC_MAP=0 order by catg_name asc", WI.fillTextValue("catg_index"), false)%> </select>
		</select>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
<%}%>	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#dddddd"><div align="center"><strong>::: List of Subject with New Assigned Category ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Sub Code </td>
      <td width="35%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Sub Name </td>
      <td width="25%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Category</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Term</td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;Delete</td>
    </tr>
    
    <%
String[] astrConvertTerm = {"Summer","1st","2nd","3rd","4th","ALL"};
for(int i=0; i<vRetResult.size(); i+=5){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=astrConvertTerm[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 4), "5"))]%></td>
      <td class="thinborder">
		<input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="DeleteRecord('<%=vRetResult.elementAt(i)%>')">	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
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
