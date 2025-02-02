<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);

boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
//function PrintPg(){
//	document.form_.print_page.value = "1";
//	this.SubmitOnce("form_");
//}

function PrintPage(){
	
	document.getElementById('header').deleteRow(1);
	document.getElementById('header').deleteRow(1);
	document.getElementById('header2').deleteRow(0);
	document.getElementById('footer_').deleteRow(0);
	
//	var strNewValue = "<div style=\"page-break-before:always\"> </div>";
//	var iMaxDisplay = document.form_.max_display.value;
	
//	for (var i = 1; i < Number(iMaxDisplay); i++){
	
//		if (eval("document.form_.checkbox"+i+".checked")){
//			eval("document.getElementById('label"+ i+"').innerHTML= '" + strNewValue +"'") ;
//		}else{
//			eval("document.getElementById('label"+ i+"').innerHTML= ''") ;
//		}
//	}
	
	window.print();
}
//  about ajax - to display student list with same name.
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

function viewInfo(){
	document.form_.print_page.value = "0";	
	this.SubmitOnce("form_");
}


function FocusID() {
<% if(!bolMyHome){%>
	document.form_.emp_id.focus();
<%}%>
}

function ReloadPage()
{
	document.form_.print_page.value = "0";	
	this.SubmitOnce("form_");
}

-->
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;



	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Personal Data","hr_cgh_201_file.jsp");
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
 iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
 										(String)request.getSession(false).getAttribute("userId"),
										"Registrar Management","REPORTS",request.getRemoteAddr(),
										"hr_cgh_201_file.jsp");
}else{
	iAccessLevel = 1;
	strTemp = (String)request.getSession(false).getAttribute("userId");	
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
Vector vContactInfo = null;
Vector vFacultyLoad = null;

boolean bNoError = false;
boolean bolNoRecord = false;
boolean bolFatalErr = false;

String strAnnualSal = null;
double dAnnualSal = 0d;

int iCtr = 1;

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
Authentication auth = new Authentication();


double[] dAnnualRange={0d,60000d,
   					   80000d,89999d,
					   150000d,249999d,					   
					   60001d,69999d,
					   90000d,99999d,
					   250000d,499999d,					   					   
					   70000d,79999d,
					   100000d,149999d,
					   500000d,0};

strTemp = WI.fillTextValue("emp_id");
String strEmpID = null;
String[] astrSemester = {"Summer", " 1st Semester ", "2nd Semester", "3rd Semester"};



//if(strTemp.length() == 0)
//	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
//else	
//	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	
//strTemp = WI.getStrValue(strTemp);

//if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0) 	
//		request.setAttribute("emp_id",strTemp);

if (strTemp.length()> 0){
	strEmpID = strTemp;
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
	

	vContactInfo = new hr.HRInfoContact().operateOnPermAddress(dbOP,request,3);
	if (vEmpRec != null && vEmpRec.size() > 0) 
		vFacultyLoad =  
			new enrollment.FacultyManagement().viewFacultyLoadSummary(dbOP,
										(String)vEmpRec.elementAt(0),
										WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
										WI.fillTextValue("semester"), "",true);
										
   strAnnualSal = dbOP.mapOneToOther("pr_salary_main","user_index",(String)vEmpRec.elementAt(0),
   								  "salary_amt", " and is_valid = 1 " + 
						          " and (('" + WI.getTodaysDate() + "' between  validity_date_fr " +
						          "   and  validity_date_to) " +
						          " or  ('" + WI.getTodaysDate() + "' >=  validity_date_fr  " +
						          "   and validity_date_to is null))");
	if (strAnnualSal != null) 
		dAnnualSal = Double.parseDouble(strAnnualSal) * 12;
}

%>
<body onLoad="FocusID();">

<form action="./hr_cgh_201_file.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr>
      <td height="25" colspan="3" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong> <br>	
        <strong> <font size="2">FACULTY INFORMATION SHEET </font></strong><br>
		<br>
		<%=astrSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"1"))]%>
		
		<%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%>
		
		</td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<% if (!bolMyHome){%>
    <tr>
      <td width="32%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16"></td>
      <td width="10%"><a href="javascript:viewInfo()"><img src="../../../images/refresh.gif" width="71" height="23" border="0"></a></td>
      <td width="58%"><label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
      <input name="emp_id2" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="header2">
	<tr>
      <td width="17%" height="25">School Year / Sem : </td>
      <td width="83%" height="25"><%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	  %>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) 
	  		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	  %>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">   <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
		strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
		if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")){
			  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
          }%>
        </select>  
	  </td>
    </tr>  
</table>
<% if (WI.getStrValue(strEmpID,"").length() > 0){ 
	 if (vRetResult != null && vRetResult.size() > 0) { %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2" valign="bottom">Employee Number : <%=strEmpID%></td>
    </tr>
    <tr>
      <td width="22%" height="25" valign="bottom">Name (Last, First, Middle) :      </td>
      <td width="78%" valign="bottom">&nbsp;<%=(String)vEmpRec.elementAt(3)%>, <%=(String)vEmpRec.elementAt(1) %> &nbsp; <%=WI.getStrValue((String)vEmpRec.elementAt(2))%>&nbsp;  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <% if (vContactInfo  != null && vContactInfo.size() > 0) {

		strTemp = WI.getStrValue((String)vContactInfo.elementAt(4));
		if (strTemp.length() > 0) 
			strTemp = dbOP.mapOneToOther("HR_PRELOAD_COUNTRY",
										"COUNTRY_INDEX", strTemp,"COUNTRY","");
		if (strTemp == null) strTemp = "";

		strTemp = WI.getStrValue((String)vContactInfo.elementAt(1)) + 
			WI.getStrValue((String)vContactInfo.elementAt(2), "," ,"","") + 
			WI.getStrValue((String)vContactInfo.elementAt(3), " ," ,"","") + 
			WI.getStrValue(strTemp," ,","","") + 
			WI.getStrValue((String)vContactInfo.elementAt(5), "  - " ,"","") ;

	 }else
		strTemp = "";
	
  %>
    <tr>
      <td height="20" colspan="2" valign="bottom">Address : <%=strTemp%> </td>
    </tr>
    <tr>
      <td width="13%" height="20" valign="bottom">Contact Nos.  : </td>
  <% if (vContactInfo != null && vContactInfo.size() > 0)
		strTemp = WI.getStrValue((String)vContactInfo.elementAt(6));
	 else
		strTemp = "";
  %> 	  
      <td valign="bottom"><span class="thinBorderBottom">&nbsp;<%=strTemp%></span></td>
    </tr>
    <tr>
      <td height="20" valign="bottom">Birth Date : </td>
	<% strTemp = (String)vEmpRec.elementAt(5);
		if(strTemp  != null && strTemp.length() > 0) 
			strTemp = WI.formatDate(strTemp, 6); %>
	  
      <td width="87%" valign="bottom">&nbsp;<%=WI.getStrValue(strTemp, "")%> </td>
    </tr>
  </table>
  <br>
<%} 
hr.HRInfoLicenseETSkillTraining iLETST  = new hr.HRInfoLicenseETSkillTraining();

Vector vLicense = iLETST.operateOnLicense(dbOP,request,4);
if(vLicense == null || vLicense.size() == 0) {
	///force it to 3 rows atleast.
	vLicense = new Vector();
	vLicense.setSize(33);
}	
else if(vLicense.size() < 33)
	vLicense.setSize(33);
if (vLicense != null && vLicense.size() > 0) {
%>
<br>

<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
  <tr align="center"> 
	<td width="100%" height="20"> <strong>PROFESSIONAL LICENSES</strong> </td>
  </tr>
</table>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinBorder">
          <tr align="center"> 
            <td width="22%" height="18" class="thinBorder">Type of Licensure Exam </td>
            <td width="16%" class="thinBorder">Date Taken </td>
            <td width="11%" class="thinBorder">Rating</td>
            <td width="12%" class="thinBorder">License <br>
            Number </td>
          </tr>
          <% for (int i = 0; i < vLicense.size() ; i+=11) { %>
          <tr> 
            <td height="20" class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+1),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+10),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+9),"&nbsp;")%></td>
            <td class="thinBorder"><%=WI.getStrValue((String)vLicense.elementAt(i+2),"&nbsp;")%></td>
          </tr>
          <%} // end for loop %>
  </table>
<%}
request.setAttribute("order_by"," order by order_no desc");
Vector vEducList  = new hr.HRInfoEducation().operateOnEducation(dbOP,request, 4);
if(vEducList == null || vEducList.size() == 0) {
	///force it to 3 rows atleast.
	vEducList = new Vector();
	vEducList.setSize(28 * 3);
	vEducList.setElementAt("Baccalaureate", 21);
	vEducList.setElementAt("Masteral", 21 + 28);
	vEducList.setElementAt("Doctorate", 21 + 28 * 2);
}	
else if(vEducList.size() < 28 * 3) {
	int iSize = vEducList.size();
	vEducList.setSize(28 * 3);
	if(iSize == 28)
		vEducList.setElementAt("Masteral", 21 + 28);
	vEducList.setElementAt("Doctorate", 21 + 28 * 2);
}


if (vEducList != null && vEducList.size() > 0) {
%><br><br>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
  <tr align="center"> 
	<td width="100%" height="20"> <strong>EDUCATIONAL CREDENTIAL(S) EARNED</strong> </td>
  </tr>
</table>

<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinBorder">
    <tr align="center">
      <td width="12%" height="20" class="thinBorder">&nbsp;</td>
      <td width="25%" class="thinBorder">School</td>
      <td width="24%" class="thinBorder">Course and Major </td>
      <td width="24%" class="thinBorder">Degree</td>
      <td width="15%" class="thinBorder">Inclusive Dates </td>
    </tr>
    <% 	for (int i = 0; i < vEducList.size(); i +=28) {%>
    <tr>
      <td valign="top" class="thinBorder"><%=WI.getStrValue(vEducList.elementAt(i+21),"&nbsp;")%><br> &nbsp;       </td>
      <td valign="top" class="thinBorder"> <%=WI.getStrValue((String)vEducList.elementAt(i+22),"&nbsp")%>        </td>
      <td valign="top" class="thinBorder">
	  	<%=WI.getStrValue((String)vEducList.elementAt(i+2),"&nbsp")%>
	  	<%=WI.getStrValue((String)vEducList.elementAt(i+25),"(Major in ",")","")%> 
		<%=WI.getStrValue((String)vEducList.elementAt(i+26),"(Minor in ",")","")%>
	  </td>
      <td valign="top" class="thinBorder"><%if(vEducList.elementAt(i) != null){%>
	  <% if ( WI.getStrValue((String)vEducList.elementAt(i+27),"1").equals("1")){%>
	  	(CAR)
	  <%}else{%>
	    <%=WI.getStrValue((String)vEducList.elementAt(i+4),"Units : <strong>","</strong>","")%>	  
  	  <%}}%> &nbsp;
	  </td>
      <td valign="top" class="thinBorder"> <%if(vEducList.elementAt(i) != null){%>Fr :
	  	<%=WI.getStrValue((String)vEducList.elementAt(i+8),"--") + "/"    + 
	  	 WI.getStrValue((String)vEducList.elementAt(i+16),"--") + "/" +
		 WI.getStrValue((String)vEducList.elementAt(i+17),"--")%> <br>
      To : <%=WI.getStrValue((String)vEducList.elementAt(i+9),"--") + "/" +
	  	 WI.getStrValue((String)vEducList.elementAt(i+18),"--") + "/" +
		 WI.getStrValue((String)vEducList.elementAt(i+19),"--")%><%}%>&nbsp;</td>
    </tr>
    <% }// end for loop %>
  </table>
<%} 

	if (vEmpRec != null && vEmpRec.size() > 0) {
%>
<br>
<br>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinBorder">
    <tr align="center">
      <td width="33%" height="38" class="thinBorder"> Employment Status </td>
      <td width="34%" class="thinBorder">Tenure of Employment </td>
      <td width="33%" class="thinBorder">Faculty Rank</td>
    </tr>

    <tr>
	<% String strPTFT = "";
	   String strTenure  = "";
	   String strRank = "";
	   
		if (vEmpRec != null && vEmpRec.size() > 0){
			strPTFT = WI.getStrValue((String)vEmpRec.elementAt(22)); 
			strTenure = WI.getStrValue((String)vEmpRec.elementAt(16)); 
			strRank = WI.getStrValue((String)vEmpRec.elementAt(26)); 			
		}
		
		
		if (strPTFT.equals("1")) 
			strTemp = "X";
		else strTemp = "&nbsp;";
	%>
      <td height="20" class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Full Time </td>
	 <%
		if (strTenure.toLowerCase().startsWith("reg")) 
			strTemp = "X";
		else strTemp = "&nbsp;";
	%>
      <td class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Tenured / Permanent </td>
	 <%
		if (strRank.toLowerCase().startsWith("instr")) 
			strTemp = "X";
		else strTemp = "&nbsp;"; %>
      <td class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Instructor </td>
    </tr>
    <tr>
	<%	if (strPTFT.equals("0")) 
			strTemp = "X";
		else strTemp = "&nbsp;"; %>
      <td height="20" class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Part Time </td>
	<%	if (!strTenure.toLowerCase().startsWith("reg")) 
			strTemp = "X";
		else strTemp = "&nbsp;"; %>	  
      <td class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Non Tenured / Contractual </td>
	<%	if (strRank.toLowerCase().startsWith("assist")) 
			strTemp = "X";
		else strTemp = "&nbsp;"; %>	
      <td class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Assistant Professor </td>
    </tr>
    <tr>
      <td height="20" class="thinBorder">&nbsp;</td>
      <td class="thinBorder">&nbsp;</td>
	<%	if (strRank.toLowerCase().startsWith("assoc")) 
			strTemp = "X";
		else strTemp = "&nbsp;"; %>		  
      <td class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Associate Professor </td>
    </tr>
    <tr>
      <td height="20" class="thinBorder">&nbsp;</td>
      <td class="thinBorder">&nbsp;</td>
	<%	if (strRank.toLowerCase().startsWith("full")) 
			strTemp = "X";
		else strTemp = "&nbsp;"; %>		  
      <td class="thinBorder">&nbsp;&nbsp;[ <%=strTemp%> ] Full Professor </td>
    </tr>
  </table>
<%}%>
<br>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinBorder">
    <tr> 
      <td width="37%" height="25" align="center" class="thinBorder"><strong>TEACHING LOAD (number of Units)
      </strong></td>
      <td width="35%" align="center" class="thinBorder"><strong>SUBJECT(S) TAUGHT </strong></td>
      <td width="28%" align="center" class="thinBorder"><strong>NUMBER OF SECTIONS </strong></td>
    </tr>
<%int iRowCount = 0;
if (vFacultyLoad!= null) {
		String strCurrentSubject = null;
		double dTotalLoad = 0d;
		int iNumSections = 0;
		Vector vSubjects = new Vector();
		int k = 0;
		boolean bolIncremented  = false;
	for(int i = 0 ; i < vFacultyLoad.size();){
		strCurrentSubject = null;
		bolIncremented = false;
		k = i;
		dTotalLoad = 0d;
		iNumSections = 0;
		
	
		while(k < vFacultyLoad.size()){
			if ((String)vFacultyLoad.elementAt(k) == null) {
				k+= 12;
				continue;
			}
			
			if (strCurrentSubject == null){
				strCurrentSubject = (String)vFacultyLoad.elementAt(k);
				i = k;				
				bolIncremented = true;
			}
			
			if (strCurrentSubject.equals((String)vFacultyLoad.elementAt(k))){
				vFacultyLoad.setElementAt(null, k);
				dTotalLoad += Double.parseDouble((String)vFacultyLoad.elementAt(k + 8));
				iNumSections++;
			}

			k += 12;
		}
		
		if (!bolIncremented)
			break; ++ iRowCount;
	%>
    <tr> 
      <td height="20" align="center" class="thinBorder"> 
			 <%=CommonUtil.formatFloat(dTotalLoad, false)%>	  </td>
      <td class="thinBorder">&nbsp;<%=strCurrentSubject%></td>
      <td align="center" class="thinBorder"><%=iNumSections%></td>
    </tr>
    <% }//end of for 
	
	}//end of if vFacultyLoad is not null
	for(; iRowCount < 4; ++iRowCount){%>
    <tr> 
      <td height="20" align="center" class="thinBorder">&nbsp;</td>
      <td class="thinBorder">&nbsp;</td>
      <td align="center" class="thinBorder">&nbsp;</td>
    </tr>
	<%}%>
  </table>

<% if (vEmpRec != null && vEmpRec.size() > 0 && false){ //removed due to request from Payroll - March 04 2010%>
<br>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="33%" height="18"><strong>Annual Salary </strong></td>
      <td width="34%" align="center">&nbsp;</td>
      <td width="33%" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" align="center">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
    <tr>
<% iCtr = 1;
   if (dAnnualSal != 0 && dAnnualSal <dAnnualRange[iCtr++])
	strTemp =  "X";  else strTemp = "&nbsp;"; %>
      <td height="18">[ <%=strTemp%> ] below 60,000 </td>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td>[ <%=strTemp%> ] 80,000 - 89,999 </td>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = " &nbsp; "; %>
      <td>[ <%=strTemp%> ] 150,000 - 249,999 </td>
    </tr>
    <tr>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td height="18">[ <%=strTemp%> ] 60,000 - 69,999 </td>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td>[ <%=strTemp%> ] 90,000 - 99,999 </td>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td>[ <%=strTemp%> ] 250,000 - 499,999 </td>
    </tr>
    <tr>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td height="18">[ <%=strTemp%> ] 70,000 - 79,999 </td>
<% if (dAnnualSal >=dAnnualRange[iCtr++]  && dAnnualSal <=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td>[ <%=strTemp%> ] 100,000 - 149,999 </td>
<% if (dAnnualSal >=dAnnualRange[iCtr++])
	strTemp = "X";  else strTemp = "  &nbsp; "; %>
      <td>[ <%=strTemp%> ] 500,000 up </td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="footer_">
  
  <tr>
    <td width="33%" height="48" align="center" valign="bottom">
		<a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>
	<font size="1">print page</font> </td>
  </tr>
</table>
<% }
 } // if (WI.getStrValue(strTemp).lenght() == 0)%>  

<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="print_page" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
