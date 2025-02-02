<%@ page language="java" import="utility.*,payroll.PRTaxStatus,payroll.PRTaxComputation,java.util.Vector,
								payroll.PRMiscDeduction"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Tax Status</title>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateDependentTStat() {
	var pgLoc = "./tax_status_update_dependents.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.emp_id.focus();
}
function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
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
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-TAX STATUS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-TAX STATUS","tax_status.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
//			dbOP.cleanUP();
//			throw new Exception();
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

/*	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Tax Status","tax_status.jsp");
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
														"tax_status.jsp");
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
*/

	PRTaxStatus prTaxStat = new PRTaxStatus();
	PRTaxComputation prTax  = new PRTaxComputation();
	PRMiscDeduction prd = new PRMiscDeduction(request);
	Vector vRetResult = null;
	Vector vDependentInfo = null;
	Vector vEmpRec    = null;
	Vector vEmpList = null;
	int iIndexOf = 0;
		
	String[] astrExemptionName    = {"Zero(No Exemption)", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 4 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
	String strTaxStatus = null;
	String strDependent = null;
		
	String strEmpIndex = null;
	double dTotalExemption = 0d;
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {

		if(prTaxStat.operateOnTaxStatus(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prTaxStat.getErrMsg();
		else {
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Tax Status Information successfully updated.";
 		}
	}



if(WI.fillTextValue("emp_id").length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null)
		strErrMsg = "Employee has no profile.";

	strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	dTotalExemption = prTax.getTaxExemptions(dbOP,strEmpIndex,WI.getTodaysDate());
}
if(vEmpRec != null && vEmpRec.size() > 0) {
	vRetResult  = prTaxStat.operateOnTaxStatus(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = prTaxStat.getErrMsg();
	else {
		vDependentInfo = prTaxStat.operateOnDependentTaxStatus(dbOP, request, 4);
	}
	vEmpList = prd.getEmployeesList(dbOP);

}

String[] astrConvertCivilStat = {"","Single","Married","Divorced/Separated","Widow/Widower"};
String[] astrConvertTaxStat   = {"Z (No Exemption)","Single","Head of Family","Married Employed"};
%>
<body bgcolor="#D2AE72" onLoad="FocusID()" class="bgDynamic">
<form action="./tax_status.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      PAYROLL : TAX STATUS PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="4" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
    <tr>
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Employee ID</td>
      <td width="19%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><br>
		<div id="ajax_" style="position:absolute; width:400px; overflow:auto">
		<label id="coa_info"></label>
		</div> </td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
	  </td>
    </tr>
  </table>
<%
if(vEmpRec != null && vEmpRec.size() > 0 && vRetResult != null && vRetResult.size() > 0) {
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="25%" height="18">&nbsp; </td>
      <td>
        <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id")+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";%>
        <%=WI.getStrValue(strTemp)%> <br> <br>
        <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
        <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
        <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
        <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font>
        <br></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
	<%
		if (vRetResult != null && vRetResult.size() > 0){
			strTemp = (String)vRetResult.elementAt(0);
		}else{
			strTemp = "0";
		}
	%>
      <td height="30" valign="bottom">Civil Status : <strong><%=astrConvertCivilStat[Integer.parseInt(strTemp)]%></strong></td>
      <td height="30">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="7%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Tax Status </td>
			<%
				if (vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(1);
				}else{
					strTemp = "1";
				}	
			%>
      <td height="25" colspan="3"><select name="tax_status">
        <option value="0">Zero (Z)</option>
        <%for( int i =1; i <= 11; ++i ){
				if(astrExemptionVal[i].equals(strTemp)){%>
        <option selected value="<%=astrExemptionVal[i]%>"><%=astrExemptionName[i]%></option>
        <%}else{%>
        <option value="<%=astrExemptionVal[i]%>"> <%=astrExemptionName[i]%></option>
        <%}
			}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Tax Dependents</td>
      <td height="25" colspan="3">
			<%if(iAccessLevel > 1){%>
			<a href="javascript:UpdateDependentTStat();"><img src="../../../images/update.gif" border="0" ></a>
        <font size="1">click to update dependents eligible for tax exemption</font>
			<%}%>	
			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25" colspan="3">
				<%if(iAccessLevel >1){%>         
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1');">
        click to update Tax status
				<%}%> 
				</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td width="18%" height="25">&nbsp;</td>
      <td colspan="2"><div align="right"></div></td>
    </tr>
    <tr bgcolor="#97ABC1">
      <td height="25" colspan="6" align="center"><strong><font color="#FFFFFF">CURRENT
      DEPENDENT TAX STATUS</font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <%
	  	if (vRetResult != null && vRetResult.size() > 0){
			strTaxStatus = (String)vRetResult.elementAt(1);
		}else{
			strTaxStatus = "";
		}	
		
		
		if(strTaxStatus.length() == 2){
			strDependent = strTaxStatus.substring(1,2);
			strTaxStatus = strTaxStatus.substring(0,1);						
		}
	  %>
      <td height="25" colspan="3">Tax Status : <strong><%=astrConvertTaxStat[Integer.parseInt(strTaxStatus)]%><%=WI.getStrValue(strDependent," "," Dependent(s)","")%></strong></td>
      <td width="18%" height="25">Total Exemption: </td>
      <td width="39%"><strong>&nbsp;&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalExemption,true),"")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">Eligible for Tax Exemption Dependents : <strong>
        <%if(vDependentInfo == null || vDependentInfo.size() == 0) {%>
			No dependent found.
        <%}else{%>
			<%=(String)vDependentInfo.remove(0)%>
        <%}%>
        </strong></td>
    </tr>
    <%
 for(int i = 0; vDependentInfo != null && i < vDependentInfo.size(); i += 10) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="5%" height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp; <%if( ((String)vDependentInfo.elementAt(i + 4)).compareTo("1") == 0) {%> <img src="../../../images/tick.gif"> <%}%> <%=(String)vDependentInfo.elementAt(i + 1)%></td>
    </tr>
    <%}%>
  </table>

<%}//show only if vEmpRec is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
