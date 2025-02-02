<%@ page language="java" import="utility.*,payroll.PRTaxStatus,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Dependents</title>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Tax Status","tax_status_update_dependents.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Payroll","TAX STATUS",request.getRemoteAddr(),
														"tax_status_update_dependents.jsp");
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

	PRTaxStatus prTaxStat = new PRTaxStatus();
	Vector vDependentInfo = null;
	Vector vEmpRec    = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prTaxStat.operateOnDependentTaxStatus(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prTaxStat.getErrMsg();
		else
			strErrMsg = "Tax Status Information successfully updated.";
	}
String[] astrRelationship ={"Spouse","Child","Brother", "Sister","Parent"};
	
if(WI.fillTextValue("emp_id").length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null)
		strErrMsg = "Employee has no profile.";
}

if(vEmpRec != null && vEmpRec.size() > 0)
	vDependentInfo  = prTaxStat.operateOnDependentTaxStatus(dbOP, request,4);	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./tax_status_update_dependents.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        DEPENDENT TAX STATUS PAGE ::::</strong></font></td>
    </tr>
	</table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
 <%
 if(vDependentInfo != null && vDependentInfo.size() > 0) {%>
  
  <table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="6"><strong><font color="#FFFFFF"> &nbsp;&nbsp;&nbsp;&nbsp; DEPENDENT'S DATA OF :::: <%=WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4)%></font></strong></td>
    </tr>
    <tr> 
      <td width="35%" height="25" align="center"><font size="1"><strong> 
      NAME</strong></font></td>
      <td width="19%" align="center"><font size="1"><strong>DATE OF BIRTH</strong></font></td>
      <td width="10%" align="center"><strong><font size="1">AGE</font></strong></td>
      <td width="13%" align="center"><font size="1"><strong>GENDER</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>RELATION</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>ELIGIBLE</strong></font></td>
    </tr>
    <%  vDependentInfo.removeElementAt(0);
	String[] astrGender = {"M","F"};
	int j = 0;
	for (int i = 0; i < vDependentInfo.size(); i +=10, ++j){
	strTemp = (String)vDependentInfo.elementAt(i + 4);
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";
	%>
    <tr> 
      <td height="25">&nbsp;<%=(String)vDependentInfo.elementAt(i + 1)%></td>
      <td align="center"> &nbsp;<%=(String)vDependentInfo.elementAt(i + 2)%></td>
      <td align="center">&nbsp;<%=CommonUtil.calculateAGEDatePicker((String)vDependentInfo.elementAt(i + 2))%></td>
      <td align="center">&nbsp;<%=astrGender[Integer.parseInt((String)vDependentInfo.elementAt(i + 3))]%></td>
      <td align="center">&nbsp;<%=astrRelationship [Integer.parseInt((String)vDependentInfo.elementAt(i + 5))]%></td>
      <td align="center"><input type="checkbox" name="checkbox<%=j%>" value="<%=(String)vDependentInfo.elementAt(i)%>"<%=strTemp%>>      </td>
    </tr>
    <% } // end for loop %>
	<input type="hidden" name="max_disp" value="<%=j%>">
    <tr> 
      <td height="40" colspan="6" align="center" valign="bottom">
        <%if(iAccessLevel >1){%>
        <a href="javascript:PageAction(1)"><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to update Tax status</font> 
        <%}%>        </td>
    </tr>
  </table>
 <%}//only if vDependentInfo is not null%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>