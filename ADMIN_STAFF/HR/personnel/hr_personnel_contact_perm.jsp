<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoContact"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;	

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function viewInfo(){
	document.staff_profile.page_action.value = "3";
	document.staff_profile.showDB.value = "1";
	this.SubmitOnce("staff_profile");
}
function AddRecord(){
	document.staff_profile.page_action.value="1";
	this.SubmitOnce("staff_profile");
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
<% if(!bolMyHome){%>
	document.staff_profile.emp_id.focus();
<%}%>
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.staff_profile.emp_id.value;
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
	document.staff_profile.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.staff_profile.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Contact Info","hr_personnel_contact_perm.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_contact_perm.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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
Vector vRetResult = new Vector();
Vector vEmpRec = new Vector();
boolean bNoError = false;
boolean bolNoRecord = false;
String strInfoIndex = WI.fillTextValue("info_index");
String strPageAction = WI.fillTextValue("page_action");

HRInfoContact hrCon = new HRInfoContact();

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}

	if (bNoError) {
		if (strPageAction.compareTo("1") == 0){
			if (hrCon.operateOnPermAddress(dbOP,request,1) != null)
				strErrMsg = " Employee permanent contact record updated successfully";
			else
				strErrMsg = hrCon.getErrMsg();
		}
		
		vRetResult = hrCon.operateOnPermAddress(dbOP,request,3);
		if (vRetResult == null) 
			if (strErrMsg == null) strErrMsg = hrCon.getErrMsg();
	}// end bNoError
}


if ((request.getParameter("showDB") == null || 
	request.getParameter("showDB").compareTo("1") == 0) 
	&& (vRetResult != null && vRetResult.size() > 0))  bolNoRecord = false;
	else bolNoRecord = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_contact_perm.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          PERMANENT ADDRESS ::::</strong></font></div></td>
    </tr>
    <tr>
      <td colspan="3"><a href="hr_personnel_contact_main.jsp?my_home=<%=request.getParameter("my_home")%>"><img src="../../../images/go_back.gif" border="0" align="left"></a>
        &nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
			<label id="coa_info"></label>
	   </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<% 	if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
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
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
        <br> <table width="95%" border="0" align="center" cellpadding="4" cellspacing="0">
<% strTemp = WI.fillTextValue("cname");
 	strTemp2 = WI.fillTextValue("street");
	strTemp3 = WI.fillTextValue("city");

	if (!bolNoRecord){
		strTemp = WI.getStrValue((String) vRetResult.elementAt(0));
		strTemp2 = (String) vRetResult.elementAt(1);
		strTemp3 = (String) vRetResult.elementAt(2);
	}
	
	if (strTemp.length() == 0) strTemp = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),1);
%>
          <tr>
            <td>&nbsp;</td>
            <td>Contact Name</td>
            <td><input name="cname" type= "text"  value ="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="25">            </td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td width="18%">Street Address</td>
            <td width="72%"><input name="street" type= "text"   value ="<%=WI.getStrValue(strTemp2,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32">            </td>
          </tr>
<% 
	strTemp = WI.fillTextValue("barangay");
	if (!bolNoRecord)
		strTemp = (String) vRetResult.elementAt(8);
%>
          <tr>
            <td>&nbsp;</td>
            <td>Barangay</td>
            <td><input name="barangay" type= "text"   value ="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="32"></td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td>City/Municipality</td>
            <td><input name="city" type= "text"   value ="<%=WI.getStrValue(strTemp3,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="32"></td>
          </tr>
<% strTemp = WI.fillTextValue("province");
 	strTemp2 = WI.fillTextValue("country");
	strTemp3 = WI.fillTextValue("zipcode");

	if (!bolNoRecord){
		strTemp = (String) vRetResult.elementAt(3);
		strTemp2 = (String) vRetResult.elementAt(4);
		strTemp3 = (String) vRetResult.elementAt(5);
	}
%>

          <tr>
            <td width="10%">&nbsp;</td>
            <td>Province</td>
            <td><input name="province" type= "text" value= "<%=WI.getStrValue(strTemp,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="16"></td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td>Country</td>
            <td><select name="country">
	  <option value="">Select Country</option>
      <%=dbOP.loadCombo("COUNTRY_INDEX","COUNTRY"," FROM HR_PRELOAD_COUNTRY",strTemp2,false)%>
	  </select> 
<%if(!bolMyHome && iAccessLevel > 1){%>
  <a href='javascript:viewList("HR_PRELOAD_COUNTRY","COUNTRY_INDEX","COUNTRY","COUNTRY",
	"hr_info_con_perm",	"COUNTRY_INDEX", " and hr_info_con_perm.is_del = 0 and hr_info_con_perm.is_valid = 1","","country")'>
	  <img src="../../../images/update.gif" border="0"></a>
              <font size="1">click to add/edit list of countries</font>			  
<%}%>
			  </td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td>Zip Code</td>
            <td><input name="zipcode" type= "text"  value= "<%=WI.getStrValue(strTemp3)%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'"
			onblur="style.backgroundColor='white'" size="12"></td>
          </tr>
<%
strTemp = WI.fillTextValue("nos");
if (!bolNoRecord) strTemp = (String) vRetResult.elementAt(6);
%>
          <tr>
            <td width="10%">&nbsp;</td>
            <td>Contact nos.</td>
            <td><input name="nos" type= "text" class="textbox"   value= "<%=WI.getStrValue(strTemp)%>"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32"></td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td colspan="2"><div align="center">
<% if (iAccessLevel > 1){%>
	<a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a>
    <font size="1">click to save entries</font>
<%}%>
              </div></td>
          </tr>
        </table>
        <hr size="1"></td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<%  // change 14
   if (!bolNoRecord){
   		strInfoIndex = (String)vRetResult.elementAt(7);
   }
%>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="showDB">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
