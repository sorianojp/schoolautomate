<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
	function PageAction(strAction, strInfoIndex){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.info_index.value = strInfoIndex;

		document.form_.submit();
	}	
	
var openImg = new Image();
openImg.src = "../../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strCType = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS","set_subject_category_uph.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"set_subject_category_uph.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
ReportFeeAssessment rfa = new ReportFeeAssessment();

String[] strCatType = {"Computer Lec","Computer Lab","RLE","Internship"};

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(rfa.operateOnUPHSubjCatg(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = rfa.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully saved.";
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully deleted.";	
	}
}
vRetResult = rfa.operateOnUPHSubjCatg(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = rfa.getErrMsg();
%>


<form name="form_" method="post" action="./set_subject_category_uph.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		PROFESSIONAL SUBJECTS MAINTENANCE PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	

	
	
	<tr><td colspan="5"><hr size="1"></td></tr>
	<tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" valign="bottom">Subject Code : <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">
	  <%
		  	strTemp = " from subject where is_del=0 order by sub_code";
			
			
	  %>
	  
	  <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; width:400px;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code", strTemp ,WI.fillTextValue("sub_index"), false)%> </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Category Type :
	  <select name="catg_type">
	  <option value="">Select Category Type</option>
	  <%
strCType = WI.fillTextValue("catg_type");	
if(strCType.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="0" <%=strErrMsg%>>Computer Lec</option>
			    <%	
if(strCType.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="1" <%=strErrMsg%> >Computer Lab</option>
			    <%	
if(strCType.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="2" <%=strErrMsg%>>RLE</option>
			    <%	
if(strCType.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="3" <%=strErrMsg%>>Internship</option>
			 </select>
			 
			
	  </td>
    </tr>
	
	<tr><td height="10" colspan="3"></td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td width="95%">
		
			<a href="javascript:PageAction('1','');"><img src="../../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save entry</font>		</td>		
	</tr>
</table>  
  
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td>
	  <div onClick="showBranch('branch6');swapFolder('folder6')">
          <img src="../../../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder6">
          <b><font color="#0000FF">Show Search Option </font></b></div>
        <span class="branch" id="branch6">
  		<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
			<tr>
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Category Type :
	  <select name="search_catg_type">
	  <option value="">Select Category Type</option>
	  <%
strCType = WI.fillTextValue("search_catg_type");	
if(strCType.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="0" <%=strErrMsg%>>Computer Lec</option>
			    <%	
if(strCType.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="1" <%=strErrMsg%> >Computer Lab</option>
			    <%	
if(strCType.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="2" <%=strErrMsg%>>RLE</option>
			    <%	
if(strCType.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
			  <option value="3" <%=strErrMsg%>>Internship</option>
			 </select>
			 
			  &nbsp;
			 <input type="image" src="../../../../../images/refresh.gif" border="0">
	  </td>
    </tr>
		</table>
      </span></td>
    </tr>
	<tr><td>&nbsp;</td></tr>
  </table>
 
 
<%
if(vRetResult != null && vRetResult.size() > 0){%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" height="23" width="15%" align="center"><strong>Category Type</strong></td>
		<td width="65%" align="center" class="thinborder"><strong>SUBJECT</strong></td>		
		<td class="thinborder" width="20%" align="center"><strong>OPTION</strong></td>
	</tr>
	<%for (int i=0; i  < vRetResult.size(); i +=4 ){%>
	<tr>
		<td class="thinborder" style="padding-left:5px;"><%=strCatType[Integer.parseInt((String)vRetResult.elementAt(i+1))]%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2) +" - "+(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" align="center">
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
			<img src="../../../../../images/delete.gif" border="0" height="23" width="40" align="absmiddle"></a>
		</td>
	</tr>
	<%}%>	
</table>
  
  <%}%>

  


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<!-- all hidden fields go here -->

	<input type="hidden" name="page_action" >
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
	<%=dbOP.constructAutoScrollHiddenField()%>	
</form>
</body>
</html>
