<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction, strInfoIndex, strMainModIndex)
{
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	if(strMainModIndex != 'null' && strMainModIndex.length > 0) 
		document.form_.main_mod_index.value = strMainModIndex;
	else	
		document.form_.main_mod_index.value = "";
		
	document.form_.auto_create_sub_module.value = '';
	document.form_.auto_create.value = "";
	document.form_.submit();
}
function ViewPossibleList() {
	var win=window.open('./manage_mod_submod_view.jsp','PrintWindow','width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function AutoCreateList() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.main_mod_index.value = "";
	document.form_.auto_create_sub_module.value = '';

	document.form_.auto_create.value = 1;
	document.form_.submit();
}
function AutoCreateSubModule() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.main_mod_index.value = "";
	document.form_.auto_create.value = '';

	document.form_.auto_create_sub_module.value = '1';
	
	document.form_.submit();
}



</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("pareparedToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","manage_mod_submod.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"manage_mod_submod.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"manage_mod_submod.jsp");}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(dbOP)).equals("1"))
	bolIsSchool = true;
	
int iCreateFor = 0;
if(!bolIsSchool)
	iCreateFor = 1;

if(strSchCode.startsWith("LHS") || strSchCode.startsWith("TSUNEISHI"))
	iCreateFor = 3;

strTemp = WI.fillTextValue("page_action");
Authentication auth = new Authentication();
auth.setIsSchool(bolIsSchool);

if(!bolIsSchool) {
	dbOP.executeUpdateWithTrans("update sub_module set is_del =1 where sub_mod_name = 'faculty'", null, null, false);
}

if(strTemp.length() > 0 && strPreparedToEdit.compareTo("0") == 0) {
	if(auth.operateOn(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = auth.getErrMsg();
	else {
		if(strTemp.compareTo("2") == 0) 
			strErrMsg = "Edit main module is successful.";
		if(strTemp.compareTo("3") == 0) 
			strErrMsg = "Delete main module is successful.";
		if(strTemp.compareTo("5") == 0) 
			strErrMsg = "Edit sub-module is successful.";
		if(strTemp.compareTo("6") == 0) 
			strErrMsg = "Delete sub-module is successful.";		
	}
}
if(WI.fillTextValue("auto_create").length() >0) {
	auth.createAuthListAuto(dbOP, iCreateFor, null);
	strErrMsg = auth.getErrMsg();
}

//if(strPreparedToEdit.compareTo("1") == 0)  -- never called to edit.. 
//	vEditInfo = auth.operateOn(dbOP, request, Integer.parseInt(strTemp));

vRetResult = auth.operateOn(dbOP, request, 9);


%>
<form name="form_" action="./manage_mod_submod.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MANAGE MODULE SUBMODULE PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" bgcolor="#FFFFDF" class="thinborder">&nbsp;&nbsp;<strong> 
        Password required to Delete any Information in this page : 
		<input type="password" name="pwd" class="textbox_bigfont"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></strong></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><strong>NOTE : </strong> <br>
        Below is the list of authentication created in your database. <br>
        Click view to see avaiable range of module - submodule authentication 
        avalable in System. <br>
        To create those list in your database click Auto Create List link. <br>
        To add any new authentication list, Please contact Support team with 
        RFC.<br>
        EDIT or DELETE Operation is available only if your database is having 
        module - submodule list not available in  System</td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"> <font size="1"><a href="javascript:ViewPossibleList();"><img src="../../../images/view.gif" border="0"></a>View 
          possible list in system. <a href="javascript:AutoCreateList();"><font size="2">Click 
          to Auto Create List</font></a></font></div></td>
    </tr>
<%}else{%>
    <tr> 
      <td height="25" class="thinborder" align="center"> 
	  	<a href="javascript:AutoCreateList();">Click to Auto Create Sub Modules</a></td>
    </tr>
<%}%>
  </table>
  
<%if(vRetResult != null && vRetResult.size() > 0) {
Vector vMainModList = auth.getMainModList(iCreateFor);
Vector vSubModList  = null;
%>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#97ABC1"> 
      <td width="43%" height="25" class="thinborder"><div align="center">&nbsp;&nbsp;<strong>MODULE 
          - SUBMODULE NAME</strong></div></td>
      <td width="57%" class="thinborder"><div align="center"><strong>OPERATION</strong></div></td>
    </tr>
    <%
	String strMainModIndex = null; 
	for(int i = 0; i < vRetResult.size(); i += 4){
	strMainModIndex = (String)vRetResult.elementAt(i);
	vSubModList = auth.getMainSubModList((String)vRetResult.elementAt(i + 1));//System.out.println(vSubModList);%>
    <tr bgcolor="#FFFFDF"> 
      <td height="25" class="thinborder">&nbsp;&nbsp;<strong><%=(String)vRetResult.elementAt(i + 1)%></strong></td>
      <td class="thinborder">&nbsp;<font size="1"> 
        <%if(!auth.bolIsExists((String)vRetResult.elementAt(i + 1),vMainModList)){%>
        <a href="javascript:PageAction(3,<%=(String)vRetResult.elementAt(i)%>,'');"><img src="../../../images/delete.gif" border="1"></a> 
        Click to remove main module 
        <%}%>
        </font> </td>
    </tr>
	<%//System.out.println((String)vRetResult.elementAt(i + 3));
	for(;i < vRetResult.size(); i += 4){
		if(strMainModIndex.compareTo((String)vRetResult.elementAt(i)) != 0) {
			i -= 4;
			break;
		}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3)," ****** NO SUB MODULE *********")%></td>
      <td class="thinborder">&nbsp;<font size="1"> 
        <%if(vRetResult.elementAt(i + 3) != null && !auth.bolIsExists((String)vRetResult.elementAt(i + 3),vSubModList)){%>
        <a href="javascript:PageAction(6,'<%=(String)vRetResult.elementAt(i + 2)%>','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="1"></a> 
        Click to remove main module 
        <%}%>
        </font></td>
    </tr>
    <%}//for loop for sub mod.
	}//outer loop for main module.
	%>
    <tr> 
      <td height="25" colspan="2" class="thinborder">&nbsp;&nbsp;<strong> </strong></td>
    </tr>
  </table>
<%}//only if vRetResult is not null;%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="pareparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index">
<input type="hidden" name="auto_create">
<input type="hidden" name="main_mod_index">

<input type="hidden" name="auto_create_sub_module">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
