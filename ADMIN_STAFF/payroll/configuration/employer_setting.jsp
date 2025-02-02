<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employer Mapping</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
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
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.reloaded.value = "";
	document.form_.submit();
}
function CancelRecord(){
	location = "./employer_setting.jsp";
}
function updateEmployer(){
	var pgLoc = "../reports/remittances/employer_profile.jsp";
	var win=window.open(pgLoc,"updateEmployer",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Employer Mapping","employer_setting.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"employer_setting.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vRetResult = null;
	String strCodeIndex  = null;
	String strType = null;
	String strFieldType = null;
	int i = 0;
	String strPageAction = WI.fillTextValue("page_action");
  	
	if(strPageAction.length() > 0){
		if(prConfig.operateOnOfficeMapping(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg =  prConfig.getErrMsg();
	}
	
	vRetResult  = prConfig.operateOnOfficeMapping(dbOP, request, 4);

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="employer_setting.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: EMPLOYER MAPPING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employer name </td>
      <td><select name="employer_index">
        <%strTemp= WI.fillTextValue("employer_index");%>
        <option value="">Select Employer Name</option>
        <%=dbOP.loadCombo("employer_index","employer_name", " from pr_employer_profile " +
				"   where is_del = 0 and is_default = 0 order by employer_name", strTemp, false)%>
      </select>
			<%if(iAccessLevel > 1){%>
      <a href='javascript:updateEmployer();'><img src="../../../images/update.gif" width="60" height="26" border="0"></a>
			<%}%>
			</td>
    </tr>
    <% 
		String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0" + 
							" and not exists(select * from pr_employer_mapping " +
							" where pr_employer_mapping.c_index = college.c_index)", strCollegeIndex,false)%>
      </select></td>
    </tr>
		
		<tr>
      <td height="25">&nbsp;</td>
      <td>Office</td>
      <td><select name="d_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <%if ((strCollegeIndex.length() == 0)){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 " +
						" and not exists(select * from pr_employer_mapping " +
						"     where pr_employer_mapping.d_index = department.d_index)", WI.fillTextValue("d_index"),false)%>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong>Note:</strong><font size="1"> Offices  that are not mapped will be included in the Main employer.<br>
      If there is only one employer, there is no need to create the mapping. </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="77%" height="25"><font size="1">
        <%if(iAccessLevel > 1){%>
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
      Click to clear <%}%></font></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="24" colspan="3" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">LIST OF 
          ITEM MAPPINGS </font></strong></td>
    </tr>
    <tr>
      <td width="41%" height="25" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">EMPLOYER</span></td>
      <td width="36%" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">OFFICE</span></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">OPTION</font></strong></td>
    </tr>
		<%for(i = 0; i < vRetResult.size();i+=4){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"","",(String)vRetResult.elementAt(i+3))%></td>
      <td class="thinborder" align="center">&nbsp;
			<%if(iAccessLevel == 2){%>
	  	<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>	  
			<%}%>
			</td>
    </tr>
		<%}%>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloaded" value="<%=WI.fillTextValue("reloaded")%>">
<input type="hidden" name="is_for_sheet" value="<%=WI.fillTextValue("is_for_sheet")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
