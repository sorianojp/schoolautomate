<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "0") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	document.form_.submit();
}

function UpdateSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.select_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.checkbox'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.checkbox'+i+'.checked = false');
		}
	}
}

function UpdateBanSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.ban_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			if (eval('document.form_.benefit_index'+i+'.checked == false'))
				eval('document.form_.ban_index'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.ban_index'+i+'.checked = false');
		}
	}
}

function updateCheck(strCounter,strInfoIndex){
	if (strInfoIndex == 1){
		if (eval('document.form_.benefit_index'+strCounter+'.checked'))
			eval('document.form_.ban_index'+strCounter+'.checked=false');
	}else{
		if (eval('document.form_.ban_index'+strCounter+'.checked'))
			eval('document.form_.benefit_index'+strCounter+'.checked=false');
	}
}

function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iCtr = 0;

	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel","sal_ben_auto_insert_res.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = -1;

if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"sal_ben_auto_insert_res.jsp");
}else{
    iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","DTR",request.getRemoteAddr(),
														"sal_ben_auto_insert_res.jsp");
}



if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home",
						"../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vRetResult = null;

hr.hrAutoInsertBenefits hrAuto = new hr.hrAutoInsertBenefits();

if (WI.fillTextValue("page_action").equals("0")){
	if (hrAuto.operateOnRestrictedBenefits(dbOP, request,0) != null) 
		strErrMsg = " Selected restrictions removed";
	else
		strErrMsg =  hrAuto.getErrMsg();
}

vRetResult = hrAuto.operateOnRestrictedBenefits(dbOP,request,4);
if (vRetResult == null) 
	strErrMsg = hrAuto.getErrMsg();

%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./sal_ben_auto_insert_res.jsp" method="post" name="form_">
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INCENTIVE MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" align="right"><a href='./sal_ben_incent_mgmt_main.jsp'><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
    </tr>
    <tr> 
      <td width="8%" height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	
<% if (vRetResult != null) {  
//	int iMaxItem = Integer.parseInt((String)vRetResult.elementAt(2));
//	int iShowItem = 1;
	
//	if (Integer.parseInt((String)vRetResult.elementAt(1)) > 
//		Integer.parseInt((String)vRetResult.elementAt(2)))
	
//		strTemp = (String)vRetResult.elementAt(2);
//	else 
//		strTemp = (String)vRetResult.elementAt(1);
%>

    <tr> 
      <td width="8%" height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="checkbox" name="select_all" 
	  		value="1" onClick="UpdateSelection()">
Select All</td>
    </tr>
<%
 String strUserIndex = "";
 int iEmpCtr = 1;
	String strTRBgColor =""; 
 for (int i = 0; i < vRetResult.size(); i+= 6, ++iCtr) {
 
 
 	if (!strUserIndex.equals((String)vRetResult.elementAt(i))){
	 	if ((iEmpCtr%2) == 0) 
			strTRBgColor= "";
		else
			strTRBgColor= "bgcolor=\"#F2F4FF\"";
	}

%> 
    <tr <%=strTRBgColor%>> 
      <td height="29">&nbsp;</td>
      <td width="61%">&nbsp;
	  <% if (strUserIndex.equals((String)vRetResult.elementAt(i))){%>  &nbsp;	  		
	  <%}else{
	  	strUserIndex = (String)vRetResult.elementAt(i);
	  %><%=iEmpCtr++%>) <%=WI.formatName((String)vRetResult.elementAt(i+2),
	  					(String)vRetResult.elementAt(i+3), 
						(String)vRetResult.elementAt(i+4),4)%>
	  <%}%>	  </td>
      <td width="31%"><input type="hidden" name="user_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">
        <input type="hidden" name="benefit_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
        <input type="checkbox" name="checkbox<%=iCtr%>" value="1">
      <%=(String)vRetResult.elementAt(i+5)%></td>
    </tr>
<%  }  %>

    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>



    <tr> 
      <td height="25" colspan="3"> 
	  	<div align="center">
	  	  <% if (iAccessLevel == 2){ %>	  	
	  	  <a href='javascript:PageAction("0");'><img src="../../../images/delete.gif" border="0" name="hide_save"></a>  <font size="1">click to delete entries</font> 
	  
	  	  
	  	  <%}%>		
      </div></td>
    </tr>
<%}%> 
  </table>
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="max_display"  value="<%=iCtr%>">
<input type="hidden" name="reload_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
