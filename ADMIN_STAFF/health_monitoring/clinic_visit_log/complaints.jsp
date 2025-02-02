<%@ page language="java" import="utility.*,health.ClinicVisitLog,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +"&opner_form_name=form_";
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	
	String strErrMsg = null;
	String strTemp = null;
	String strInfoIndex = null;

	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","comlaints.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"complaints.jsp");
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

	ClinicVisitLog CVLog = new ClinicVisitLog();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(CVLog.operateOnComplaints(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				}
		else
				strErrMsg = CVLog.getErrMsg();
	}
	
	vRetResult = CVLog.operateOnComplaints(dbOP, request, 4);
	if (strErrMsg == null)
		strErrMsg = CVLog.getErrMsg();
%>
<body bgcolor="#8C9AAA" class="bgDynamic">

<form action="complaints.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CLINIC VISIT LOG - COMPLAINTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%"  height="28">&nbsp;</td>
      <td width="15%" height="28">Complaint :</td>
      <%strTemp = WI.fillTextValue("comp_index");%>
      <td width="25%" height="28"><select name="comp_index">
          <option value="">Select Complaint</option>
			<%=dbOP.loadCombo("COMPLAINT_TYPE_INDEX","COMPLAINT_TYPE"," FROM HM_PRELOAD_COMPLAINT ORDER BY COMPLAINT_TYPE", strTemp, false)%>
        </select></td>
      <td width="57%" height="28"><font size="1">
       <a href='javascript:viewList("HM_PRELOAD_COMPLAINT","COMPLAINT_TYPE_INDEX","COMPLAINT_TYPE","COMPLAINTS",
	"HM_CV_COMPLAINT","COMPLAINT_TYPE_INDEX"," AND VISIT_LOG_INDEX IS NOT NULL ","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click 
        to update list of complaints</font>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:self.close();"><img src="../../../images/close_window.gif" border="0"></a>
        </td>
    </tr>
    <tr>
    	<td width="18%"  height="28" colspan="2">&nbsp;</td>
    	<td width="25%" height="28"><a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to add entry</font></td>
    	<td width="57%" height="28"></td>
    </tr>
   
    <tr> 
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size()>0){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: COMPLAINTS ::::</strong></font></div></td>
    </tr>
    <tr>
    <td width="14%">&nbsp;</td>
    <td width="64%" height="25"><div align="center"><font size="2"><strong>Complaint</strong></font></div></td>
    <td width="10%">&nbsp;</td>
    <td width="12%">&nbsp;</td>
    </tr>
<%for(int i =0; i<vRetResult.size(); i+=2){%>
    <tr>
    <td>&nbsp;</td>
    <td><div align="center"><%=(String)vRetResult.elementAt(i)%></div></td>
    <td><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i+1)%>")'><img src="../../../images/delete.gif" border="0"></a></td>
    <td>&nbsp;</td>
    </tr>
    <%}%>
</table>
<%}%>
<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="visit_index" value="<%=WI.fillTextValue("visit_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
