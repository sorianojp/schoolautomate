<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond)+"&opner_form_name=form_" ;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%@ page language="java" import="utility.*,osaGuidance.GDPsychological ,java.util.Vector " %>
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
								"Admin/staff-Guidance & Counseling-Psychological Cases","referral.jsp");
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
														"Guidance & Counseling","Psychological Cases",request.getRemoteAddr(),
														"referral.jsp");
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

	GDPsychological GDPsych = new GDPsychological();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDPsych.operateOnReferral(dbOP, request, Integer.parseInt(strTemp)) != null )
				strErrMsg = "Operation successful.";
		else
				
				strErrMsg = GDPsych.getErrMsg();
	}
	vRetResult = GDPsych.operateOnReferral(dbOP, request, 4);
	if (strErrMsg == null)
		strErrMsg = GDPsych.getErrMsg();
%>
<body bgcolor="#663300">
<form action="./referral.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="4" bgcolor="A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PSYCHOLOGICAL CASES - REFERRAL REASONS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%"  height="28">&nbsp;</td>
      <td width="15%" height="28">Referral reason :</td>
      <%strTemp = WI.fillTextValue("res_index");%>
      <td width="25%" height="28"><select name="res_index">
          <option value="">Select reason</option>
			<%=dbOP.loadCombo("REF_REASON_TYPE_INDEX","REASON_NAME"," FROM GD_PSY_REF_REASON_TYPE ORDER BY REASON_NAME", strTemp, false)%>
        </select></td>
      <td width="57%" height="28"><font size="1">
      <a href='javascript:viewList("GD_PSY_REF_REASON_TYPE","REF_REASON_TYPE_INDEX","REASON_NAME","TESTS",
	"GD_PSY_REF_REASON","REF_REASON_TYPE_INDEX"," AND PSY_RESULT_INDEX IS NOT NULL ","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click 
        to update list of reasons</font>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:self.close();"><img src="../../../images/close_window.gif" border="0"></a></td>
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
      <td height="28" colspan="4" bgcolor="A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: REASONS FOR REFERRAL ::::</strong></font></div></td>
    </tr>
    <tr>
    <td width="14%">&nbsp;</td>
    <td width="64%" height="25"><div align="center"><font size="2"><strong>Reason Name</strong></font></div></td>
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
<input type="hidden" name="psyc_res_index" value="<%=WI.fillTextValue("psyc_res_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>