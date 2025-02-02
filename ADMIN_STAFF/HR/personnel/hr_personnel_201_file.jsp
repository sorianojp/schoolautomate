<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
	
	if (WI.fillTextValue("print_page").equals("1")){%>
		<jsp:forward page="./hr_personnel_201_file_print.jsp" />
	<%	return;}

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

td.thinBorderBottom {
	border-bottom:1px solid #000000;
}

.thinBorderALL {
	border-bottom:1px solid #000000;
	border-left: 1px solid #000000;
	border-right: 1px solid #000000;
	border-top: 1px solid #000000;
}

body{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;	
}

TD.thinBorder{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	border-bottom:1px solid #000000;
	border-left: 1px solid #000000;
}

TABLE.thinBorder{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	border-right:1px solid #000000;
	border-top: 1px solid #000000;
}

TD{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;	
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
//function PrintPg(){
//	document.staff_profile.print_page.value = "1";
//	this.SubmitOnce("staff_profile");
//}

function PrintPg(){	
	document.getElementById('header').deleteRow(2);
	document.getElementById('footer').deleteRow(0);
	
	<%if(bolAUF){%>
	var empID = document.staff_profile.emp_id.value;
    var tbl = document.getElementById('header');
  	var row = tbl.insertRow(2);
	
	var cellLeft = row.insertCell(0);
  	var textNode = document.createTextNode('Employee ID: '+empID);
  	cellLeft.appendChild(textNode);
	<%}%>
	
	
	var strNewValue = "<div style=\"page-break-before:always\"> </div>";
	var iMaxDisplay = document.staff_profile.max_display.value;
	
	for (var i = 1; i < Number(iMaxDisplay); i++){
	
		if (eval("document.staff_profile.checkbox"+i+".checked")){
			eval("document.getElementById('label"+ i+"').innerHTML= '" + strNewValue +"'") ;
		}else{
			eval("document.getElementById('label"+ i+"').innerHTML= ''") ;
		}
	}
	
	window.print();
}

function viewInfo(){
	document.staff_profile.page_action.value = "0";
	document.staff_profile.showDB.value = "1";
	document.staff_profile.print_page.value = "0";	
	this.SubmitOnce("staff_profile");
}

function viewEmpTypes(){
	var win=window.open("./hr_emp_type.jsp","myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function FocusID() {
	if (document.staff_profile.dob && document.staff_profile.dob.value.length > 0){
		UpdateAge();
	}
<% if(WI.fillTextValue("my_home").compareTo("1") != 0){%>
	document.staff_profile.emp_id.focus();
<%}%>
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.staff_profile.print_page.value = "0";	
	document.staff_profile.showDB.value="0";
	this.SubmitOnce("staff_profile");
}

function ChangeState(strFrmObject,strState){
	document.staff_profile.print_page.value = "0";	
	if (eval(strState) == 0) {
		eval("document."+strFrmObject+".readOnly =true");
		eval('document.'+strFrmObject+'.style.backgroundColor ="#CCCCCC"');

	}else {
		eval("document."+strFrmObject+".readOnly =false");
		eval("document."+strFrmObject+".style.backgroundColor ='#FFFFFF'");
	}
}


function viewCivilStatus(){
	document.staff_profile.print_page.value = "0";	
	var pgLoc = "./hr_emp_change_cs.jsp?emp_id=" + escape(document.staff_profile.emp_id.value)+"&my_home="
	+document.staff_profile.my_home.value;
	var win=window.open(pgLoc,"viewCivilStatus",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddMoreCollege() {
	document.staff_profile.print_page.value = "0";	
	if(document.staff_profile.emp_id.value.length == 0){
		alert("Please enter employee ID.");
		return;
	}
	//pop window here. 
	var loadPg = "../../user_admin/profile_add_more.jsp?emp_id="+escape(document.staff_profile.emp_id.value);
	var win=window.open(loadPg,"AddMoreCollege",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
// end ajax
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Personal Data","hr_personnel_201_file.jsp");

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
int iAccessLevel = -1;

if (!bolMyHome) {
 iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_201_file.jsp");
}
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
Vector vRetResult = null;
Vector vEmpRec = null;
boolean bNoError = false;
boolean bolNoRecord = false;
boolean bolFatalErr = false;

String[] astrCStatus = {"","Single","Married", "Divorced/Separated", "Widow/Widower","Annuled","Living Together"};
String[] astrBloodType = {"","A","B", "AB", "0"};
String[] astrBloodGroup = {"+","-"};
String[] astrLiveDead = {"Deceased", ""};
int iCtr = 1;

String[] astrRelationship ={"Spouse","Child","Brother", "Sister","Parent"};
String[] astrGender ={"Male","Female","&nbsp;"};
Vector vDependent = new hr.HRInfoDependent().operateOnSpChild(dbOP, request, 4);

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
Authentication auth = new Authentication();

int iAction =  -1;
int iDepSize = 18;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"0"));

strTemp = WI.fillTextValue("emp_id");

if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0) 	
		request.setAttribute("emp_id",strTemp);

if (strTemp.length()> 0){
	if (iAction == 1 || iAction  == 2){
		vRetResult = hrPx.operateOnPersonalData(dbOP,request,iAction);

		switch(iAction){
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Operation Successful";
				else
					strErrMsg = hrPx.getErrMsg();
				break;
			}
		} //end switch
	} //  if (iAction == 1 || ..)
	
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
	vRetResult = hrPx.operateOnPersonalData(dbOP,request,0);

	if (vRetResult == null || vRetResult.size()==0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = hrPx.getErrMsg();
	}
}

if ((request.getParameter("showDB") == null || 
	request.getParameter("showDB").compareTo("1") == 0) 
	&& (vRetResult != null && vRetResult.size() > 0))  bolNoRecord = false;
	else bolNoRecord = true;

if ((request.getParameter("showDB") == null || 
	request.getParameter("showDB").compareTo("1") == 0) 
	&& (vEmpRec != null && vEmpRec.size() > 0))  bolFatalErr = false;
	else bolFatalErr = true;

boolean bolCleanUp = false;

if (!WI.fillTextValue("emp_id").equals(WI.fillTextValue("curr_emp_id")))
	bolCleanUp = true;

//new hr.hrAutoInsertBenefits().getAutoBenefitsGovt(dbOP);



%>
<body onLoad="FocusID();">
<!--<body class="bgDynamic" onLoad="FocusID();">-->

<form action="./hr_personnel_201_file.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr>
      <td height="25" colspan="3">
<div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong> <br>
	<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
	<font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> <br><br><br>
    <strong> PERSONNEL DATA 201 FILE </strong>
</div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>	  </td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a><label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
      <input name="emp_id2" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<% if (WI.getStrValue(strTemp,"").length() > 0){%>
  
  <% if (vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="400" border="0" align="center">
    <tr bgcolor="#FFFFFF">
      <td width="100%" valign="middle"><%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
          <%=WI.getStrValue(strTemp)%> <br>
          <br>
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
          <br>
          <strong><%=WI.getStrValue(strTemp)%></strong><br>
          <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
          <font size="1"><%=WI.getStrValue(strTemp3)%></font><br>
          <br>
          <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>		  
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> </td>
    </tr>
  </table>
  <%}%>
<% if (vRetResult != null && vRetResult.size() > 0) { %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="8" bgcolor="#E0E9E9"><strong>&nbsp;PERSONAL DATA </strong></td>
    </tr>
    <tr>
      <td width="10%" height="25" valign="bottom">Name
        <%
	if (bolCleanUp) strTemp = "";
	else strTemp = WI.fillTextValue("fname");

	if(!bolFatalErr) strTemp = (String)vEmpRec.elementAt(1);
%> 
      :      </td>
      <td colspan="7" valign="bottom" class="thinBorderBottom">&nbsp;<%=(String)vEmpRec.elementAt(1) %> &nbsp; <%=WI.getStrValue((String)vEmpRec.elementAt(2))%>&nbsp; <%=(String)vEmpRec.elementAt(3)%> </td>
    </tr>
    <tr>
      <td height="20" valign="bottom">Gender : </td>
      <td width="12%" valign="bottom" class="thinBorderBottom">&nbsp;
          <%
	strTemp = WI.getStrValue((String)vEmpRec.elementAt(4));
	if (strTemp.equals("0")) strTemp = "Male";
	else
		if (strTemp.equals("1")) strTemp = "Female";
	else 
		strTemp = "";
%>
      <%=strTemp%> </td>
      <td width="16%" valign="bottom"><div align="right">Birth Date : </div></td>
      <td width="12%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue(vEmpRec.elementAt(5), "")%></td>
      <td width="8%" valign="bottom"><div align="right">Age : </div></td>
      <td width="10%" valign="bottom" class="thinBorderBottom">&nbsp;
      <script language="javascript">   
	var	strDateToday = "<%=WI.getTodaysDate(1)%>";
	var strDOB = "<%=WI.getStrValue(vEmpRec.elementAt(5), "")%>";
	if (strDOB.length > 0) 
		document.write(calculateAge(strDOB,strDateToday,true));
    </script>      </td>
      <td width="12%" valign="bottom"><div align="right">Religion : </div></td>
      <td width="20%" valign="bottom" class="thinBorderBottom">&nbsp;
        <% 
		if (WI.getStrValue((String)vRetResult.elementAt(3)).length()  > 0){%>
        <%=dbOP.mapOneToOther("HR_PRELOAD_RELIGION", "RELIGION_INDEX",WI.getStrValue((String)vRetResult.elementAt(3)),"RELIGION","")%>
      <%}%></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">Civil Status:</td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;<%=astrCStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(0),"1"))]%> </td>
      <td valign="bottom"><div align="right">Place of Birth&nbsp;:</div></td>
      <td colspan="5" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(1))%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="12%" height="20" valign="bottom">SSS Number: </td>
      <td width="15%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(4))%></td>
      <td width="5%" valign="bottom"><div align="right">TIN : </div></td>
      <td width="15%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(5))%></td>
      <td width="12%" valign="bottom"><div align="right">Philhealth : </div></td>
      <td width="17%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(16))%></td>
      <td width="9%" valign="bottom"><div align="right">Pag-ibig:</div></td>
      <td width="15%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(17))%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="bottom">
      <td width="11%" height="20">Nationality&nbsp;:</td>
      <td width="21%" class="thinBorderBottom">&nbsp;
            <% if (WI.getStrValue((String)vRetResult.elementAt(2)).length() > 0){%>
            <%=dbOP.mapOneToOther("HR_PRELOAD_NATIONALITY", "NATIONALITY_INDEX",(String)vRetResult.elementAt(2),"NATIONALITY","")%>
      <%}%>      </td>
      <td width="9%"><div align="right">Height: </div></td>
      <td width="15%" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(10),""," cm","")%></td>
      <td width="10%"><div align="right">Weight: </div></td>
      <td width="15%" class="thinBorderBottom">&nbsp;
	  	<%=WI.getStrValue((String)vRetResult.elementAt(11),"", " lbs", "")%>	  </td>
      <td width="11%"><div align="right">Blood Type:</div></td>
      <td width="8%" class="thinBorderBottom">&nbsp;
	  	<%=astrBloodType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(12),"0"))]%> 
		<% if ((String)vRetResult.elementAt(12) != null){%>
		   <%=astrBloodGroup[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(13),"0"))]%>
      <%}%>      </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="20%" height="20" valign="bottom">Distinguishing Marks&nbsp;:</td>
			<td width="80%" colspan="7" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(22))%> </td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="15%" height="20" valign="bottom">Father's Name:</td>
			<td width="49%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(6))%>&nbsp;
				<% if ( WI.getStrValue((String)vRetResult.elementAt(19),"1").equals("0")) {%>
					(deceased)
				<%}%></td>
			<td width="13%" align="right" valign="bottom">Occupation:&nbsp; </td>
			<td width="23%" valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(7))%></td>
		</tr>
		<tr>
			<td height="20" valign="bottom">Mother's Name : </td>
			<td valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(8))%>&nbsp;
				<% if ( WI.getStrValue((String)vRetResult.elementAt(20),"1").equals("0")) {%>
					(deceased)
				<%}%></td>
			<td align="right" valign="bottom">Occupation:&nbsp; </td>
			<td valign="bottom" class="thinBorderBottom">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(9))%></td>
		</tr>
	</table>
  <br>
<%if(strSchCode.startsWith("TAMIYA") && WI.getStrValue((String)vRetResult.elementAt(0)).equals("2")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<%
		strTemp = "&nbsp;";
		int iCnt = 0;
		
		if(vDependent != null && vDependent.size() > 0){
		  for (int i = 0; i < vDependent.size(); i +=iDepSize){ 
				if (((String)vDependent.elementAt(i+2)).equals("0")){
					strTemp = WI.formatName((String)vDependent.elementAt(i+4),(String)vDependent.elementAt(i+5),
								 (String)vDependent.elementAt(i+6),4);
					for(;iCnt < iDepSize; iCnt++)
						vDependent.remove(i);
					break;
				}
			}
		}
		%>
    <tr>
      <td width="15%" height="20">Spouse :</td>
      <td width="30%" class="thinBorderBottom">&nbsp;<%=strTemp%></td>
      <td width="15%">Marital Date : </td>
      <td width="40%" class="thinBorderBottom"><%=WI.getStrValue(hrPx.getLatestEmpMaritalRecord(dbOP, request),"&nbsp;")%></td>
    </tr>
  </table>
	<%}%>	  	
<%}%>  

<% 
	hr.HRInfoContact hrCon = new hr.HRInfoContact();
	Vector vContactInfo = hrCon.operateOnPermAddress(dbOP,request,3);

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" bgcolor="#E0E9E9"><strong>&nbsp;CONTACT INFORMATION </strong></td>
    </tr>
  </table>
	<%if(strSchCode.startsWith("CEBUEASY") || strSchCode.startsWith("TAMIYA")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="20"><u>Current Address :</u></td>
			<% 
			strTemp = null;
			if (vEmpRec != null && vEmpRec.size() > 0)
				strTemp = (String)vEmpRec.elementAt(8);
			strTemp = WI.getStrValue(strTemp);
			%>
      <td width="85%" class="thinBorderBottom">&nbsp;<%=strTemp%></td>
    </tr>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" colspan="4"><u>Permanent Address : </u></td>
    </tr>
    <tr>
      <td width="15%" height="20" valign="bottom">Street Address : </td>
	  <% if (vContactInfo  != null && vContactInfo.size() > 0) 
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(1));
		 else
		 	strTemp = "";
	  %>
	  
      <td width="43%" valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%> </td>
      <td width="18%" valign="bottom"><div align="right">Barangay : </div></td>
	  <% if (vContactInfo  != null && vContactInfo.size() > 0) 
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(8));
		 else
		 	strTemp = "";
	  %>	  
      <td width="24%" valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <% if (vContactInfo  != null && vContactInfo.size() > 0) {
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(2));
	  		strTemp2 = WI.getStrValue((String)vContactInfo.elementAt(3));
		}
		else {
		 	strTemp = "";
		 	strTemp2 = "";
		}
	  %>
    <tr>
      <td height="20" valign="bottom">City/Municipality</td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%></td>
      <td valign="bottom">State/Province:</td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp2%></td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td width="15%" height="20" valign="bottom">Country</td>
	  <% if (vContactInfo  != null && vContactInfo.size() > 0) {
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(4));
			if (strTemp.length() > 0) 
				strTemp = dbOP.mapOneToOther("HR_PRELOAD_COUNTRY",
											"COUNTRY_INDEX", strTemp,"COUNTRY","");
				if (strTemp == null) strTemp = "";
		 }else
		 	strTemp = "";
	  %>	  
      <td width="21%" valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%> </td>
      <td width="11%" valign="bottom"><div align="right">ZipCode:</div></td>
	  <% if (vContactInfo  != null && vContactInfo.size() > 0) 
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(5));
		 else
		 	strTemp = "";
	  %>		  
      <td width="29%" valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%> </td>
      <td width="11%" valign="bottom">&nbsp;</td>
	  <% if (vContactInfo != null && vContactInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(5));
		 else
		 	strTemp = "";
	  %>   

      <td width="13%" valign="bottom">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="20" valign="bottom">Email Address  : </td>
	  <% if (vRetResult != null && vRetResult.size() > 0)
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(21));
		 else
		 	strTemp = "";
	  %> 
      <td valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%> </td>
    </tr>
    <tr>
      <td height="20" valign="bottom">Contact Nos.  : </td>
	  <% if (vContactInfo != null && vContactInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vContactInfo.elementAt(6));
		 else
		 	strTemp = "";
	  %> 	  
      <td width="85%" valign="bottom" class="thinBorderBottom">&nbsp;<%=strTemp%></td>
    </tr>
  </table>
<% Vector vEmrContact = hrCon.operateOnEmerAddress(dbOP,request,4);
	if (vEmrContact != null && vEmrContact.size() > 0) {%>
<br>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinBorder">
          <tr> 
            <td height="20" colspan="5" bgcolor="#E0E9E9" class="thinBorder"><strong>EMERGENCY CONTACT INFORMATION </strong>: </td>
    </tr>
          <tr align="center" bgcolor="#FFFFFF"> 
            <td width="24%" height="25" class="thinBorder">Name</td>
            <td width="13%" class="thinBorder">Relation</td>
            <td width="17%" class="thinBorder">Mobile #</td>
            <td width="15%" class="thinBorder">Home #</td>
            <td width="16%" class="thinBorder">Office #</td>
          </tr>
          <% for (int i=0; i < vEmrContact.size() ; i+=8) {
	strTemp = (String) vEmrContact.elementAt(i);
	strTemp2 = (String) vEmrContact.elementAt(i+5);
	strTemp3 = (String) vEmrContact.elementAt(i+1);
%>
          <tr bgcolor="#FFFFFF"> 
            <td height="25" bgcolor="#FFFFFF" class="thinBorder"><%=WI.getStrValue(strTemp)%><br> <%=WI.getStrValue(strTemp2)%><br> </td>
            <td align="center" bgcolor="#FFFFFF" class="thinBorder">&nbsp;<%=WI.getStrValue(strTemp3)%></td>
            <%
	strTemp = (String)vEmrContact.elementAt(i+2);
	strTemp2 = (String)vEmrContact.elementAt(i+3);
	strTemp3 = (String) vEmrContact.elementAt(i+4);
%>
            <td align="center" bgcolor="#FFFFFF" class="thinBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
            <td align="center" bgcolor="#FFFFFF" class="thinBorder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
            <td align="center" bgcolor="#FFFFFF" class="thinBorder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
          </tr>
          <% } // end for loop %>
  </table>
<% } // end vRetResult != null

if (vDependent != null && vDependent.size() > 0) {
%>
<br>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinBorder">
          <tr> 
            <td height="20" colspan="5" bgcolor="#E0E9E9"  class="thinBorder"><strong>DEPENDENT'S INFORMATION            </strong>
              <strong>:  </strong></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="31%" height="20" align="center" class="thinBorder"> Name </td>
			<td width="19%" align="center" bgcolor="#FFFFFF"  class="thinBorder">Relation</td>
			<td width="19%" align="center" bgcolor="#FFFFFF" class="thinBorder">Date of Birth </td>
			<td width="15%" align="center" bgcolor="#FFFFFF" class="thinBorder">Age</td>
			<td width="16%" align="center" bgcolor="#FFFFFF" class="thinBorder">Gender</td>
          </tr>
<%  for (int i = 0; i < vDependent.size(); i +=iDepSize){ 
		if (((String)vDependent.elementAt(i+2)).equals("0") && !strSchCode.startsWith("AUF"))
			continue;
%>
          <tr> 
            <td height="20"  class="thinBorder">&nbsp;
			  <%=WI.formatName((String)vDependent.elementAt(i+4),(String)vDependent.elementAt(i+5),
								 (String)vDependent.elementAt(i+6),4)%></td>
			<td  class="thinBorder"><%=astrRelationship[Integer.parseInt((String)vDependent.elementAt(i+2))]%></td>
            <td align="center"  class="thinBorder"><%=(String)vDependent.elementAt(i+7)%></td>
            <td align="center"  class="thinBorder"><%=(String)vDependent.elementAt(i+13)%></td>
            <td align="center"  class="thinBorder" ><%=astrGender[Integer.parseInt(WI.getStrValue((String)vDependent.elementAt(i+8),"2"))]%></td>
          </tr>
          <% } // end for loop %>
  </table>
<%} // end vDependents %>




<%
Vector vEmpHist  = new hr.HRInfoPrevEmployment().operateOnPrevEmployment(dbOP,request,4);

if (vEmpHist != null && vEmpHist.size() > 0) { 
%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinBorder">
          <tr>
            <td height="20" colspan="3" bgcolor="#E0E9E9" class="thinBorder"> <strong>PREVIOUS EMPLOYERS</strong> : </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="39%" height="20" class="thinBorder" > <div align="center">Employer
            / Address</div></td>
            <td width="37%" class="thinBorder"><div align="center">Position
            / Office / Department</div></td>
            <td width="24%" class="thinBorder"><div align="center">Inclusive
            Dates</div></td>
          </tr>
<% for (int i = 0; i < vEmpHist.size() ; i+=16) { %>
          <tr bgcolor="#FFFFFF">
            <td bgcolor="#FFFFFF" class="thinBorder"> <%=WI.getStrValue((String)vEmpHist.elementAt(i),"&nbsp;")%><br>
              <%=WI.getStrValue((String)vEmpHist.elementAt(i+1),"&nbsp;")%><br>
            <%=WI.getStrValue((String)vEmpHist.elementAt(i+2),"&nbsp;")%> </td>
            <td align="center" class="thinBorder"><%=WI.getStrValue((String)vEmpHist.elementAt(i+3),"&nbsp;")%><br>
              <%=WI.getStrValue((String)vEmpHist.elementAt(i+4),"&nbsp;")%></td>
            <td class="thinBorder">&nbsp;<%=WI.getStrValue((String)vEmpHist.elementAt(i+6),"&nbsp;") + WI.getStrValue((String)vEmpHist.elementAt(i+7)," - ","","&nbsp;")%></td>
          </tr>
	<%} // end for loop %>
  </table>
<%}

Vector vEducList  = new hr.HRInfoEducation().operateOnEducation(dbOP,request, 4);

if (vEducList != null && vEducList.size() > 0) {
%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinBorder">
    <tr bgcolor="#EAF5D8">
      <td height="20" colspan="4" bgcolor="#E0E9E9" class="thinBorder"><strong><font color="#333333">EDUCATIONAL RECORD</font></strong> : </td>
    </tr>
    <tr align="center">
      <td width="19%" height="25" class="thinBorder">Education</td>
      <td width="35%" class="thinBorder">School</td>
      <td width="26%" class="thinBorder">Degree</td>
      <td width="20%" class="thinBorder">Honors / Awards </td>
    </tr>
    <% 	for (int i = 0; i < vEducList.size(); i +=28) {%>
    <tr>
      <td valign="top" class="thinBorder"><font size="1"><strong><%=(String)vEducList.elementAt(i+21)%><br>
        </strong> Fr :<%=WI.getStrValue((String)vEducList.elementAt(i+8),"--") + "/"    + 
	  	 WI.getStrValue((String)vEducList.elementAt(i+16),"--") + "/" +
		 WI.getStrValue((String)vEducList.elementAt(i+17),"--")%>	
	  	<br>To : <%=WI.getStrValue((String)vEducList.elementAt(i+9),"--") + "/" +
	  	 WI.getStrValue((String)vEducList.elementAt(i+18),"--") + "/" +
		 WI.getStrValue((String)vEducList.elementAt(i+19),"--")%>	

</font> </td>
      <td valign="top" class="thinBorder"> <font size="1"><strong><%=WI.getStrValue((String)vEducList.elementAt(i+22),"&nbsp")%><br>
        </strong> <%=WI.getStrValue((String)vEducList.elementAt(i+23),"&nbsp")%>
		<br>Date Graduated : <%=WI.getStrValue((String)vEducList.elementAt(i+3),"--") + "/" +
	  	 WI.getStrValue((String)vEducList.elementAt(i+14),"--") + "/" +
		 WI.getStrValue((String)vEducList.elementAt(i+15),"--")%>			
		</font></td>
      <td valign="top" class="thinBorder">
	  <% if ( WI.getStrValue((String)vEducList.elementAt(i+27),"1").equals("1")) {%>
	  	(Completed Academic Requirements)
	  <%}%>
	  <%=WI.getStrValue((String)vEducList.elementAt(i+2),"&nbsp")%> <%=WI.getStrValue((String)vEducList.elementAt(i+25),"(Major in ",")","")%> <%=WI.getStrValue((String)vEducList.elementAt(i+26),"(Minor in ",")","")%>
	  <%=WI.getStrValue((String)vEducList.elementAt(i+4),"<br> Units : <strong>","</strong>","")%>	  </td>
	  
<%
	strTemp = WI.getStrValue((String)vEducList.elementAt(i+24));

	if (strTemp.length() == 0) 
		strTemp = WI.getStrValue((String)vEducList.elementAt(i+11),
								"Awards: ","","&nbsp;");
	else
		strTemp = WI.getStrValue((String)vEducList.elementAt(i+11),
								"<br>Awards: ","","");	  
%>	  
      <td valign="top" class="thinBorder"><font size="1"><%=WI.getStrValue(strTemp,"&nbsp")%></font></td>
    </tr>
    <% }// end for loop %>
  </table>
<%}

Vector vAwards  = new hr.HRInfoScholarship().operateOnScholarship(dbOP,request,4);

if (vAwards != null && vAwards.size() > 0) { 
%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinBorder">
    <tr> 
      <td height="20" colspan="5" bgcolor="#E0E9E9" class="thinBorder"><strong>AWARDS / CITATIONS : </strong></td>
    </tr>
    <tr align="center"> 
      <td width="17%" class="thinBorder">Reward Type </td>
      <td width="23%" class="thinBorder">Name</td>
      <td width="23%" class="thinBorder">Granting Agency / Org </td>
      <td width="15%" class="thinBorder">Date </td>
      <td width="22%" class="thinBorder">Place</td>
    </tr>
    <% for (int i =0 ; i < vAwards.size() ; i+=13){ %>
    <tr> 
      <td class="thinBorder"><%=WI.getStrValue((String)vAwards.elementAt(i+8))%></td>
      <td class="thinBorder"><%=WI.getStrValue((String)vAwards.elementAt(i+1))%></td>
      <td class="thinBorder"><%=WI.getStrValue((String)vAwards.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinBorder"><%=WI.getStrValue((String)vAwards.elementAt(i+4),"&nbsp;")%></td>
      <td class="thinBorder"><%=WI.getStrValue((String)vAwards.elementAt(i+5),"&nbsp;")%></td>
    </tr>
    <%} // end for loop %>
  </table>
<%}

 Vector vResearchWork = new hr.HRInfoResearchWork().operateOnResearchWork(dbOP,request,4);
 
if (vResearchWork != null && vResearchWork.size() > 0) {%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" cellpadding="5" cellspacing="0"  class="thinBorder">
	  <tr bgcolor="#FFF2F4"> 
		<td height="20" colspan="6" bgcolor="#E0E9E9" class="thinBorder"><strong>RESEARCH WORK /SCHOLARSHIPS : </strong></td>
	  </tr>
	  <tr align="center">
		<td width="14%" class="thinBorder">Work Type  :: Specification </td>
		<td width="20%" class="thinBorder">Research Work Title </td>
		<td width="12%" class="thinBorder">Status</td>
		<td width="17%" class="thinBorder">Granting Agency / Org </td>
		<td width="8%" class="thinBorder">Date</td>
		<td width="15%" class="thinBorder">Place</td>
	  </tr>
	  <% for (int i = 0; i < vResearchWork.size(); i +=14) {%>
	  <tr>
		<td class="thinBorder"><%=WI.getStrValue((String)vResearchWork.elementAt(i+9))%>
	    <%=WI.getStrValue((String)vResearchWork.elementAt(i+11)," :: ","","")%></td>
		<td class="thinBorder"> <%=WI.getStrValue((String)vResearchWork.elementAt(i+2),"&nbsp;")%></td>
		<td class="thinBorder"><%=WI.getStrValue((String)vResearchWork.elementAt(i+8),"&nbsp;")%></td>
		<td class="thinBorder"><%=WI.getStrValue((String)vResearchWork.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinBorder"><%=WI.getStrValue((String)vResearchWork.elementAt(i+5),"&nbsp;")%></td>
		<td class="thinBorder"><%=WI.getStrValue((String)vResearchWork.elementAt(i+6),"&nbsp;")%></td>
	  </tr>
	  <%} // end for loop%>
  </table>
<%} // end vRetResult listing of Research Works 

hr.HRInfoLicenseETSkillTraining iLETST  = new hr.HRInfoLicenseETSkillTraining();

Vector vLicense = iLETST.operateOnLicense(dbOP,request,4);

if (vLicense != null && vLicense.size() > 0) {
%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinBorder">
          <tr> 
            <td height="20" colspan="5" bgcolor="#E0E9E9" class="thinBorder"><strong>LICENSES</strong> : </td>
          </tr>
          <tr align="center"> 
            <td width="22%" height="25" class="thinBorder">License Name </td>
            <td width="16%" class="thinBorder">License No. </td>
            <td width="11%" class="thinBorder">Issued Date </td>
            <td width="12%" class="thinBorder">Expiry Date </td>
            <td width="23%" class="thinBorder">Remarks</td>
          </tr>
          <% for (int i = 0; i < vLicense.size() ; i+=11) { %>
          <tr> 
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+1),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+2),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+3),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+4),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+6),"&nbsp;")%></td>
          </tr>
          <%} // end for loop %>
  </table>
<%}
Vector vExams = iLETST.operateOnExamTaken(dbOP,request,4);
 
   if (vExams != null && vExams.size() > 0) { 
   	String[] astrRatingSelect= {"%","marks","points","percentile","GPA"};
 %>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinBorder">
          <tr> 
            <td height="20" colspan="6" bgcolor="#E0E9E9" class="thinBorder"><strong>EXAMS RECORD:</strong></td>
          </tr>
          <tr align="center"> 
            <td width="20%" height="20" class="thinBorder">Title of Exam</td>
            <td width="9%" class="thinBorder">Date Taken</td>
            <td width="20%" class="thinBorder">Place Taken</td>
            <td width="7%" class="thinBorder">Rank</td>
            <td width="8%" class="thinBorder">Rating</td>
            <td width="21%" class="thinBorder">Remarks</td>
          </tr>
     <% for (int i = 0; i < vExams.size() ; i+=9) {
		strTemp = WI.getStrValue((String)vExams.elementAt(i+5));
		if (strTemp.length() != 0){
			if (!strTemp.startsWith("0"))
				strTemp += " " + 
				astrRatingSelect[Integer.parseInt(WI.getStrValue((String)vExams.elementAt(i+6),"0"))];
			else
				strTemp = "&nbsp;";
				}
				else strTemp = "&nbsp;";
		   %>
          <tr> 
            <td class="thinBorder"><%=WI.getStrValue((String)vExams.elementAt(i+1),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vExams.elementAt(i+2),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vExams.elementAt(i+3),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vExams.elementAt(i+4),"&nbsp;")%></td>
            <td class="thinBorder"><%=strTemp%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vExams.elementAt(i+7),"&nbsp;")%></td>
          </tr>
          <%} // end for loop %>
  </table>
<%}
Vector vTrainings = iLETST.operateOnTraining(dbOP,request,4);

if (vTrainings != null && vTrainings.size() > 0) {
String[] astrSemimarType={"N/A","Official Time","Official Business","Representative/Proxy",""};
 %>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinBorder">
          <tr> 
            <td height="20" colspan="4" bgcolor="#E0E9E9" class="thinBorder"><strong>&nbsp;TRAINING/SEMINAR RECORD</strong></td>
          </tr>
          <tr> 
            <td width="31%" height="20" align="center" class="thinBorder">Training / Seminar </td>
            <td width="19%" align="center" class="thinBorder">Type / Budget </td>
            <td width="26%" align="center" class="thinBorder">Venue / Place </td>
            <td width="11%" align="center" class="thinBorder">Date</td>
          </tr>
          <% for (int i=0; i < vTrainings.size() ; i+=19) { %>
          <tr> 
            <td height="20" class="thinBorder">&nbsp;<%=WI.getStrValue((String)vTrainings.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String)vTrainings.elementAt(i+6),"<br> Conducted by : ","","")%></td>
            <td class="thinBorder">&nbsp;
			<%//=astrSemimarType[Integer.parseInt(WI.getStrValue((String)vTrainings.elementAt(i+14),"0"))]%> 
			<%=WI.getStrValue((String)vTrainings.elementAt(i+18)," - ")%>
			<%=WI.getStrValue((String)vTrainings.elementAt(i+13)," <br> &nbsp;Budget :","","")%></td>
            <td class="thinBorder">&nbsp;<%=WI.getStrValue((String)vTrainings.elementAt(i+3),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vTrainings.elementAt(i+7),"&nbsp;") + 
				WI.getStrValue((String)vTrainings.elementAt(i+8),"<br>&nbsp; to ", "","")%></td>
          </tr>
          <%} // end for loop %>
  </table>
<%} %>
<br>


<%Vector vSkills = iLETST.operateOnSkills(dbOP,request,4);
  Vector vLanguage = new hr.HRInfoLanguage().operateOnLanguage(dbOP,request,4);
  
	String astrConvLevel[] = {"Beginner", "Intermediate","Advance","Expert"};

	if ((vSkills != null && vSkills.size() > 0)  || (vLanguage != null && vLanguage.size() > 0)) { 
 %>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
<td width="49%" valign="top">
<%
  if (vSkills != null && vSkills.size() > 0) { 

 %>
        <table width="99%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinBorder">
          <tr>
            <td height="20" colspan="3" bgcolor="#E0E9E9" class="thinBorder"> <strong>SKILLS <%if(bolAUF){%>(SELF-ASSESSMENT) <%}%>: </strong></td>
          </tr>
          <tr>
            <td width="53%" height="20" class="thinBorder">&nbsp;&nbsp;Skills Name </td>
            <td width="22%" align="center" class="thinBorder">Yrs of Use </td>
            <td align="center" class="thinBorder">Level</td>
          </tr>
<%  for (int i=0; i < vSkills.size() ; i +=5) { %>
          <tr>
            <td height="20" class="thinBorder"><font size="1"><%=WI.getStrValue((String)vSkills.elementAt(i+1))%></font></td>
            <td class="thinBorder"><font size="1"><%=WI.getStrValue((String)vSkills.elementAt(i+2))%></font></td>
            <td width="25%" class="thinBorder"><font size="1"><%=astrConvLevel[Integer.parseInt((String)vSkills.elementAt(i+3))]%></font></td>
          </tr>
          <%} // end for loop  %>
        </table>
<%} // end if skills vector exists%>
</td>
<td width="51%" valign="top">
<% 
	if (vLanguage != null && vLanguage.size() > 0) {
	String astrConvFScale[] = {"Beginner","Intermediate","Advance","Expert"};
    String strTemp1 = null;
%>
		<table width="99%" border="0" cellpadding="0" cellspacing="0" class="thinBorder">
          <tr>
            <td height="20" colspan="6" bgcolor="#E0E9E9" class="thinBorder"><strong> &nbsp;LANGUAGES <%if(bolAUF){%>(SELF-ASSESSMENT) <%}%>: </strong></td>
          </tr>
          <tr>
            <td width="30%" class="thinBorder">&nbsp;Language</td>
            <td width="11%" align="center" class="thinBorder">Speak</td>
            <td width="9%" align="center" class="thinBorder">Read</td>
            <td width="10%" height="20" align="center" class="thinBorder">Write</td>
            <td width="14%" align="center" class="thinBorder">All</td>
            <td width="26%" class="thinBorder">Fluency</td>
          </tr>
<%
	for (int i=0; i < vLanguage.size();i+=5) {%>
          <tr>
            <td height="20" class="thinBorder"><%=(String)vLanguage.elementAt(i+1)%></td>
            <% strTemp = "&nbsp;";strTemp2 = "&nbsp;"; strTemp3 = "&nbsp;";strTemp1 = "&nbsp;";
	if ((String)vLanguage.elementAt(i+2)!=null)
		switch(Integer.parseInt((String)vLanguage.elementAt(i+2))){
		case 0: strTemp = "<img src=\"../../../images/tick.gif\"> "; break;
		case 1: strTemp1 = "<img src=\"../../../images/tick.gif\"> "; break;
		case 2: strTemp2 = "<img src=\"../../../images/tick.gif\"> "; break;
		case 3: strTemp3 = "<img src=\"../../../images/tick.gif\"> "; break;
	}
%>
            <td align="center" class="thinBorder"><%=strTemp%></td>
            <td align="center" class="thinBorder"><%=strTemp1%></td>
            <td align="center" class="thinBorder"><%=strTemp2%></td>
            <td align="center" class="thinBorder"><%=strTemp3%></td>
            <td class="thinBorder">&nbsp;<%=astrConvFScale[Integer.parseInt((String)vLanguage.elementAt(i+3))]%></td>
          </tr>
          <%}//end for loop%>
        </table>
<%}// end table listing%>		  
</td>
</tr>
</table>
<%
} // show table if vskills or vlanguage is not null;


hr.HRInfoGAExtraActivityOffense hrGExtraO = new hr.HRInfoGAExtraActivityOffense();
Vector vAffiliation  = hrGExtraO.operateOnGroupAffiliation(dbOP,request,4);

if (vAffiliation != null && vAffiliation.size() > 0) {
%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinBorder">
          <tr>
            <td height="20" colspan="4" bgcolor="#E0E9E9" class="thinBorder"><strong>&nbsp;GROUP  AFFILIATIONS : </strong></td>
          </tr>
          <tr align="center">
            <td width="23%" height="20" class="thinBorder"> <p align="left"> Name of Organization<font size="1"><strong> <br>
                </strong></font></p></td>
            <td width="23%" class="thinBorder">Place (Station) </td>
            <td width="16%" class="thinBorder">Position</td>
            <td width="21%" class="thinBorder">Inclusive Dates </td>
    </tr>
<% for (int i=0; i < vAffiliation.size() ; i+=6) {
	strTemp = WI.getStrValue((String)vAffiliation.elementAt(i+3));
	if (strTemp.length() > 0){
		strTemp += WI.getStrValue((String)vAffiliation.elementAt(i+4), " to " ,"", " to present");
	}else strTemp = "&nbsp;";
%>
          <tr>
            <td height="20" class="thinBorder"><%=(String)vAffiliation.elementAt(i)%><br>              </td>
            <td class="thinBorder"><%=WI.getStrValue((String)vAffiliation.elementAt(i+1),"&nbsp")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vAffiliation.elementAt(i+2),"&nbsp")%></td>
            <td class="thinBorder"><%=WI.getStrValue(strTemp)%></td>
    </tr>
<%}// end for loop%>
  </table>
<%} // end for listing table vAffiliation

Vector vExtraAct = hrGExtraO.operateOnExtraActivities(dbOP, request, 4);

if (vExtraAct != null && vExtraAct.size() > 0)  {
%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinBorder">
  <tr bgcolor="#EAF7F0">
    <td height="20" colspan="5" bgcolor="#E0E9E9" class="thinBorder"><strong>EXTRA ACTIVITIES/SERVICES : </strong></td>
  </tr>
  <tr align="center">
    <td width="15%" height="20" class="thinBorder"><font size="1"><strong>TYPE OF SERVICE/ACTIVITY</strong></font></td>
    <td width="19%" class="thinBorder"><font size="1"><strong>NAME/NATURE OF ACTIVITY/PROJECT</strong></font></td>
    <td width="20%" class="thinBorder"><font size="1"><strong>NATURE OF PARTICIPATION/SERVICE</strong></font></td>
    <td width="11%" class="thinBorder"><font size="1"><strong>DATE</strong></font></td>
    <td width="20%" class="thinBorder"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
  <% for (int i = 0; i < vExtraAct.size(); i+=7) {%>
  <tr>
    <td height="20" class="thinBorder"><%=WI.getStrValue((String)vExtraAct.elementAt(i+1),"&nbsp;")%></td>
    <td class="thinBorder"><%=WI.getStrValue((String)vExtraAct.elementAt(i+2),"&nbsp;")%></td>
    <td class="thinBorder"><%=WI.getStrValue((String)vExtraAct.elementAt(i+3),"&nbsp;")%></td>
    <td align="center" class="thinBorder"><%=WI.getStrValue((String)vExtraAct.elementAt(i+4),"&nbsp;")%></td>
    <td class="thinBorder"><%=WI.getStrValue((String)vExtraAct.elementAt(i+5),"&nbsp;")%></td>
    </tr>
  <%} //end for loop%>
</table>
<%}

Vector vOffenses = hrGExtraO.operateOnOffenses(dbOP, request,4);

if (vOffenses != null && vOffenses.size() > 0)  {

%>
<br><label id="label<%=iCtr%>">
<input type="checkbox" name="checkbox<%=iCtr++%>" value="1"> check to put page break
</label>

<table width="100%" border="0" cellpadding="0"  class="thinBorder" cellspacing="0">
  <tr>
    <td height="20" colspan="5" bgcolor="#E0E9E9" class="thinBorder"><strong>&nbsp; OFFENSE(S)</strong></td>
  </tr>
  <tr>
    <td width="20%"  class="thinBorder"><p align="center"><font size="1"><strong> OFFENSE(S)<br>
    </strong></font></p></td>
    <td width="21%" align="center" class="thinBorder"><font size="1"><strong>DETAILS</strong></font></td>
    <td width="15%" class="thinBorder"><div align="center"><font size="1"><strong>DATE OF 
      OFFENSE/REPORTED</strong></font></div></td>
    <td width="10%" align="center" class="thinBorder"><font size="1"><strong>ACTION 
      TAKEN</strong></font></td>
    <td width="10%" align="center" class="thinBorder"><font size="1"><strong>EFFECTIVE 
      DATE(S)</strong></font></td>
  </tr>
  <% 
  /****************************** updated to Preload Table  ****************************
  
 	String astrConvAction[] = {"Warning","Written Reprimand", "1st Notice", "2nd Notice","Suspension", "Termination"};
	if (strSchCode.startsWith("CPU")) {
		astrConvAction[0] = "Verbal";
		astrConvAction[1] = "Verbal Reprimand";
		astrConvAction[2] = "1st Written Warning";
		astrConvAction[3] = "2nd Written Warning";
		astrConvAction[4] = "Suspension";
		astrConvAction[5] = "Termination";
	}
	
	if (strSchCode.startsWith("CGH")) {
		astrConvAction[0] = "Written Reprimand";
		astrConvAction[1] = "Verbal Reprimand";
		astrConvAction[2] = "Suspension";
		astrConvAction[3] = "Dismissal";
		astrConvAction[4] = null;
		astrConvAction[5] = null;
	}
	**************************************************************************/
		
  for (int i=0; i < vOffenses.size(); i+=9) {%>
  <tr>
    <td class="thinBorder" height="23"><%=WI.getStrValue((String)vOffenses.elementAt(i+1),"&nbsp")%></td>
    <td class="thinBorder"><%=WI.getStrValue((String)vOffenses.elementAt(i+2),"&nbsp")%></td>
    <td align="center" class="thinBorder"><%=WI.getStrValue((String)vOffenses.elementAt(i+3),"&nbsp")%></td>
    <td class="thinBorder"><%=WI.getStrValue((String)vOffenses.elementAt(i+8),"&nbsp;")%></td>
    <td align="center" class="thinBorder">
      <%=WI.getStrValue((String)vOffenses.elementAt(i+5),"&nbsp;")+ 
			WI.getStrValue((String)vOffenses.elementAt(i+7)," - " ,"","")%></td>
  </tr>
  <%} // end for loop%>
</table>

<%}%> 
  <table width="95%" border="0" cellpadding="0" cellspacing="0" id="footer">
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="98%" align="center"><% if ( iAccessLevel > 1){%>
          <% if (vEmpRec != null && vEmpRec.size() > 0 && vRetResult != null && vRetResult.size() > 0) { %><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print profile</font>
          <%}%>
        <%}%>
      &nbsp;</td>
    </tr>
  </table>
<% if (vEmpRec != null && vEmpRec.size() > 0 && vRetResult != null && vRetResult.size() > 0) { %>
	  <table width="95%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td>Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
		</tr>
	  </table>
<%}

} // if (WI.getStrValue(strTemp).lenght() == 0)%>  

<input type="hidden" name="reloadPage"> 
<input type="hidden" name="page_action">
<input type="hidden" name="showDB" value="0">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="print_page" value="0">
<input type="hidden" name="curr_emp_id" value="<%=WI.fillTextValue("emp_id")%>">
<input type="hidden" name="max_display" value="<%=iCtr%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
