<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script>
function AddDtls(strInfoIndex) {
	var loadPg = "./selection_dtls.jsp?setup_ref="+strInfoIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=1160,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
		dbOP = new DBOperation();
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

LmsAcquision lmsAcq = new LmsAcquision();
Vector vRetResult     = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(lmsAcq.operateOnBookSelectionMain(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = lmsAcq.getErrMsg();
	else	
		strErrMsg = "Request processed successfully.";
}
vRetResult = lmsAcq.operateOnBookSelectionMain(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = lmsAcq.getErrMsg();

%>
<body bgcolor="#FAD3E0">
<form action="./selection.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: ACQUISITION - BOOK SELECTION  PAGE ::::</strong></font></div></td>
    </tr>
</table>
<jsp:include page="./inc.jsp?pgIndex=3"></jsp:include>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="3" height="25" style="font-weight:bold; font-size:12px; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      </tr>
      <tr>
        <td width="8%">School Year : </td>
        <td width="12%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">		</td>
        <td>
		  <input type="submit" name="_1" value="Reload Page" onClick="document.form_.page_action.value=''">
		  </td>
      </tr>
      <tr>
        <td>College :</td>
        <td colspan="2">
<%
strTemp = WI.fillTextValue("c_index");
%>
<select name="c_index" onChange="document.form_.info_index.value='';document.form_.page_action.value='';document.form_.submit();">
          <option value="">Select a College (Optional)</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",strTemp, false)%> 
          </select>	
		  </td>
      </tr>
      <tr>
        <td>Course</td>
        <td colspan="2">
<%
if(strTemp.length() == 0) 
	strTemp = " from course_offered where is_valid = 1 and is_offered = 1 order by course_code";
else	
	strTemp = " from course_offered where is_valid = 1 and is_offered = 1 and c_index = "+strTemp+" order by course_code";
%>
<select name="course_index" onChange="document.form_.info_index.value='';document.form_.page_action.value='';document.form_.submit();">
          <%=dbOP.loadCombo("course_index","course_code + '::' +course_name",strTemp,WI.fillTextValue("course_index"), false)%> 
          </select>		</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td colspan="2">
		<input type="submit" name="_1" value="Create Selection Reference" onClick="document.form_.page_action.value='1';">		</td>
      </tr>
	</table>
<%if(vRetResult != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#9DB6F4">
    <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF" ><strong>::::
      LIST OF BOOKS SELECTION FOR ACQUISITION  ::::</strong></font></td>
    </tr>
  <tr>
    <td height="25" colspan="7" class="thinborder" style="font-weight:bold; font-size:11px;"> Total Selections created : <%=vRetResult.size()/7%></td>
    </tr>
  <tr bgcolor="#C6D3F4" align="center" style="font-weight:bold">
    <td width="5%" class="thinborder" align="center">Count</td>
    <td width="15%" height="25" class="thinborder">Setup Reference # </td>
    <td width="25%" class="thinborder">Course Name </td>
    <td width="10%" class="thinborder">Total Books encoded </td>
    <td width="15%" class="thinborder">Books encoded in Acquisition </td>
    <td width="10%" class="thinborder">Add Books </td>
    <td width="10%" class="thinborder">Delete</td>
  </tr>
  
<%for(int i = 0; i < vRetResult.size(); i += 7){
strTemp = (String)vRetResult.elementAt(i + 5);%>
  <tr>
    <td class="thinborder"><%=i/7 + 1%>.</td>
    <td height="20" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=strTemp%></td>
    <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
    <td class="thinborder"><a href="javascript:AddDtls('<%=vRetResult.elementAt(i)%>');"><font color="#FF0000">Add Books</font></a></td>
    <td class="thinborder"><input name="submit22" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" value="DELETE" onClick="document.form_.page_action.value='0'; document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'"></td>
  </tr>
<%}%>
</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#0D3371">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>