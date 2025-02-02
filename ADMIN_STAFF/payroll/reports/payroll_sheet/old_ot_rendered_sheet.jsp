<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
	WebInterface WI = new WebInterface(request);
	String strHeaderSize = WI.getStrValue(WI.fillTextValue("header_size"), "10");
	String strDetailSize = WI.getStrValue(WI.fillTextValue("detail_size"), "10");

	if(WI.fillTextValue("print_page").length() > 0){ %>
		<jsp:forward page="./ot_rendered_sheet_print.jsp" />
	<%}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Overtime Rendered</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
	}	
	
	TD.thinborderHeader {
		border-left: solid 1px #000000;
		border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>px;
	}

</style>
</head>

<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.form_.print_page.value = "";
		document.form_.proceed_.value=1;
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}	

///ajax here to load dept..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	String strHasWeekly = null;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Summary of OT Rendered","old_ot_rendered_sheet.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");		
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
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"PAYROLL","REPORTS",
											request.getRemoteAddr(),"old_ot_rendered_sheet.jsp");

if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"Last Name(Requested for)","Department",strTemp};

String[] astrSortByVal     = {"lname","d_name","c_name"};

String[] astrMonth = {"January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

int iSearchResult = 0;
ReportEDTRExtn RE = new ReportEDTRExtn(request);
String strMonth = null;
String strYear = null;
Vector vRetResult = null;
Vector vOtTypes = new Vector();
Vector vUserOT = null;
int iOtTypeCount = 0;
int j = 0;
int iIndexOf = 0;
Long lIndex = null;
double[] adHours = null;
double[] adOTRates = null;
double[] adHourlyRates = null;
double[] adHourAmt = null;
double[] adMinAmt = null;
double dTotal = 0d;

double dTemp = 0d;
double dRegOtHour = 0d;
double dHourlyRate = 0d;
int iWidth = 7;
String strAmount = null;
double dOtRate = 0d;
double dExcessRate = 0d;
double dExcessHr = 0d;
double dHalfMonth = 0d;
double dGross = 0d;
double dTax = 0d;
double dNet = 0d;

String strRateType = null;
String strExcessType = null;

	int iHours = 0;
	int iMinutes = 0;
	double dHourAmt = 0d;
	double dMinAmt = 0d;

if (WI.fillTextValue("proceed_").equals("1")){

	vRetResult = RE.generateOTRendered(dbOP);
	if (vRetResult == null){
		strErrMsg =  RE.getErrMsg();
	}else{
		vOtTypes = (Vector)vRetResult.remove(0);
		vRetResult.remove(0);// remove dates
		iSearchResult = RE.getSearchCount();
		
		if(vOtTypes != null){
			iOtTypeCount = vOtTypes.size() / 7;
			iWidth = 54/ (iOtTypeCount * 6);
 			adHours = new double[iOtTypeCount];
			adHourlyRates = new double[iOtTypeCount];
			adHourAmt = new double[iOtTypeCount];
			adMinAmt = new double[iOtTypeCount];
		}
	}
}
%>
<form action="./old_ot_rendered_sheet.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        OVERTIME REQUEST VIEW PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="2">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr>
      <td>&nbsp;</td>
      <td width="19%" height="25">Month / Year </td>
			<%strTemp = WI.fillTextValue("month_of");%>
      <td width="79%" height="25">
			<select name="month_of">
        <option value="">&nbsp;</option>
        <%for (i = 0; i < astrMonth.length; i++) {
			if (strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrMonth[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrMonth[i]%></option>
        <%}
			}%>
      </select>

      <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
      </select>
        <font size="1">(this option will overwrite the date range encoded above)</font></td>
    </tr>
    
    <tr> 
      <td width="2%">&nbsp; </td>
      <td height="25">Employee ID</td>
      <td height="25"><input name="emp_id" type="text"  size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
    </tr>
    <% if (strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td>&nbsp;</td>
      <td height="24">Employment Catg</td>
			<%
				strTemp = WI.fillTextValue("emp_type_catg");
			%>
      <td height="24"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				for(i = 0;i < astrCategory.length;i++){
					if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Position</td>
      <td height="25"><strong> 
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
					WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
					" order by EMP_TYPE_NAME asc", strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="24"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
			%>
      <td height="24"><select name="c_index" onChange="loadDept();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Department/Office</td>
      <td height="25">
			<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>			</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Office/Dept filter<br></td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
		
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>			</td>
    </tr>
		<%}%>
    <tr> 
      <td height="12" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>    
    <tr>
      <td width="17%" height="21" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="83%" bgcolor="#FFFFFF">
			<input name="btn_proceed" type="button" onClick="ViewRecords();" value="Proceed" 
			style="font-size:11px; height:28px;border: 1px solid #FF0000;">      </td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="26" colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td  width="10%" bgcolor="#FFFFFF"><strong>Sort By </strong></td>
    <td width="28%" bgcolor="#FFFFFF"><select name="sort_by1">
      <option value="" selected>N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
					if(WI.fillTextValue("sort_by1").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="28%" bgcolor="#FFFFFF"><select name="sort_by2">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
				if(WI.fillTextValue("sort_by2").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="34%" bgcolor="#FFFFFF"><select name="sort_by3">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <% if(WI.fillTextValue("sort_by3").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
  </tr>
  <tr>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>
<% if (vRetResult != null){ %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="4">&nbsp;</td>
	  <%
			strTemp = WI.fillTextValue("show_all");
			if (strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = ""; %>	
    <td colspan=2 align="right"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
check to show all result </td>
  </tr>
  <tr>
    <td colspan="4">&nbsp;</td>
			<%
				strTemp2 = WI.fillTextValue("header_size");
				if(strTemp2.length() == 0)
					strTemp2 = "10";
			%>		
    <td colspan=2 align="right"><font size="2">Font size of header:
        <select name="header_size">
          <%for(i = 8; i < 14; i++){%>
          <%if(strTemp2.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=i%> px</option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> px</option>
          <%}
						}%>
        </select>
    </font></td>
  </tr>
  <tr>
    <td colspan="4">&nbsp;</td>
			<%
				strTemp2 = WI.fillTextValue("detail_size");
				if(strTemp2.length() == 0)
					strTemp2 = "10";
			%>		
    <td colspan=2 align="right"><font size="2">Font size of details:
        <select name="detail_size">
          <%for(i = 8; i < 14; i++){%>
          <%if(strTemp2.equals(Integer.toString(i))){%>
          <option value="<%=i%>" selected><%=i%> px</option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> px</option>
          <%}
						}%>
        </select>
    </font></td>
  </tr>
  <tr>
    <td colspan="4"><b>Total Requests: <%=iSearchResult%> 
	  <%if(strTemp.length() == 0){%>- Showing(<%=RE.getDisplayRange()%>) <%}%></b></td>
    <td width="26%">&nbsp;</td>
    <td width="31%" align="right">
	<% 
 	if(WI.fillTextValue("show_all").length() == 0){
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) 
		++iPageCount;
	if (strTemp.length() == 0 && iPageCount > 1) {%> 
	Jump To page:
      <select name="jumpto" onChange="ViewRecords();">
   <% 
	
	
	strTemp = request.getParameter("jumpto");
	
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
		for( i =1; i<= iPageCount; ++i ){
			if(i == Integer.parseInt(strTemp) ){%>
        <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%
				}
		}
	%>
      </select>	  
	<%}
	}%>		
	</td>
  </tr>
  <tr bgcolor="#F4FBF5">
    <td height="25" colspan="6" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME RENDERED
    </strong></font></td>
  </tr>
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="14%" height="26" rowspan="2" align="center" class="thinborderHeader"><strong>NAMES</strong></td>
				<td width="3%" rowspan="2" align="center" class="thinborderHeader">MONTHLY RATE </td>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<%
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
        <td colspan="2" align="center" class="thinborderHeader"><strong><%=strTemp%></strong></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
				<td colspan="2" align="center" class="thinborderHeader"><strong><%=strTemp%></strong></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
				<td colspan="2" align="center" class="thinborderHeader"><strong><%=strTemp%></strong></td>
				<%}%>
				<td width="5%" rowspan="2" align="center" class="thinborderHeader"><strong>TOTAL</strong></td>
        <td width="4%" rowspan="2" align="center" class="thinborderHeader">50% mo. rate </td>
        <td width="5%" rowspan="2" align="center" class="thinborderHeader">GROSS AMOUNT  </td>
        <td width="5%" rowspan="2" align="center" class="thinborderHeader">WITH HOLDING TAX </td>
        <td width="5%" rowspan="2" align="center" class="thinborderHeader">NET AMOUNT </td>
        </tr>
      <tr>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">No. Hrs </td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">No. mins </td>
			  <%}%>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Rate/ Hr</td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Rate/ Min.</td>
			  <%}%>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>								
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Amount/ Hour</td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Amount/ Min</td>								
				<%}%>
				</tr>
        <%
			int iCtr = 1;
			for (i=0 ; i < vRetResult.size(); i+=20, iCtr++){ 
				vUserOT = (Vector)vRetResult.elementAt(i+11);
				strTemp = (String)vRetResult.elementAt(i+15);
				dHourlyRate = Double.parseDouble(strTemp);
				dTotal = 0d;
				// initialize array
				for(j=0; j < iOtTypeCount;j++){
					adHours[j] = 0d;				
					adHourAmt[j] = 0d;							
					adMinAmt[j] = 0d;
				}
		 %>
      <tr>
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);
						//strTemp += "<br>(" + (String)vRetResult.elementAt(i+1) + ")";
				%>
        <td height="19" nowrap class="thinborder">&nbsp;<%=strTemp%></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+14);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dHalfMonth = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					dHalfMonth = dHalfMonth/2;
				%>
        <td align="right" nowrap class="thinborder"><%=strTemp%>&nbsp;</td>
        <%				
				for(j = 0; j < vOtTypes.size(); j+=7){		
					iHours = 0;
					iMinutes = 0;
								
					dOtRate = Double.parseDouble((String)vOtTypes.elementAt(j+3));
					strRateType = (String)vOtTypes.elementAt(j+4);					
					
					dExcessRate = Double.parseDouble(WI.getStrValue((String)vOtTypes.elementAt(j+5), "0"));
					strExcessType = WI.getStrValue((String)vOtTypes.elementAt(j+6));
					
					lIndex = (Long)vOtTypes.elementAt(j);
					iIndexOf = vUserOT.indexOf(lIndex);					
					while(iIndexOf != -1){
						dExcessHr = 0d;
						iIndexOf = iIndexOf - 3;
						vUserOT.remove(iIndexOf);// 1remove user index
						vUserOT.remove(iIndexOf);// 2date
						dTemp = ((Double)vUserOT.remove(iIndexOf)).doubleValue();// 3remove hours
						vUserOT.remove(iIndexOf);// 4remove otTypeIndex
						vUserOT.remove(iIndexOf);// 5remove hourly rate
						vUserOT.remove(iIndexOf);// 6 free
						vUserOT.remove(iIndexOf);// 7 free
						
						adHours[j/7] += dTemp;
						
						dRegOtHour = dTemp;
            if (dTemp > 8) {
              dExcessHr = dTemp - 8;
              dRegOtHour = 8;
            }						
						
						//if(strExcessType.equals("0")){ // percentage
						//	adAmount[j/7] += (dExcessRate / 100) * dHourlyRate * dExcessHr;		
						//}else{ // specific rate
						//	adAmount[j/7] += dExcessHr * dHourlyRate;		
						//}

						iIndexOf = vUserOT.indexOf(lIndex);
					}
					
					if(adHours[j/7] > 0d){
						iHours = (int)adHours[j/7];
						dTemp = adHours[j/7] - iHours;
						iMinutes = (int)(dTemp*60);						
						dHourAmt = iHours * dHourlyRate;
						dMinAmt = iMinutes * dHourlyRate/60;					
						strTemp = CommonUtil.formatFloat(adHours[j/7], false) + " hr(s)";
					} else {
						strTemp = "-";
					}

					if(strRateType.equals("0")){ // percentage
						adHourlyRates[j/7] = dHourlyRate * (dOtRate / 100);
						strTemp = CommonUtil.formatFloat(adHourlyRates[j/7], 2);
						
						strTemp = ConversionTable.replaceString(strTemp, ",","");
						adHourlyRates[j/7] = Double.parseDouble(strTemp);
						
						adHourAmt[j/7] = adHourlyRates[j/7] * iHours;
						adMinAmt[j/7] = adHourlyRates[j/7]/60 * iMinutes;
					}else if(strRateType.equals("1")){ // specific rate
						adHourlyRates[j/7] = dHourlyRate;

						adHourAmt[j/7] = adHourlyRates[j/7] * iHours;						
						adMinAmt[j/7] = adHourlyRates[j/7]/60 * iMinutes;
					}else{ // flat rate	
						adHourlyRates[j/7] = dOtRate;
						adHourAmt[j/7] = dOtRate;
						adMinAmt[j/7] = 0d;
					}
					
					dTotal += adHourAmt[j/7] + adMinAmt[j/7];
				%>
				<%
					strTemp = Integer.toString(iHours);
					if(iHours == 0)
						strTemp = "&nbsp;";
				%>				
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%
					strTemp = Integer.toString(iMinutes);
					if(iMinutes == 0)
						strTemp = "&nbsp;";
				%>				
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(adHourlyRates[j/7], 2)%></td>
				<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(adHourlyRates[j/7]/60, 2)%></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
				<%
					strTemp = CommonUtil.formatFloat(adHourAmt[j/7], true);
					if(adHourAmt[j/7] == 0d)
						strTemp = "--";
				%>
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%
					strTemp = CommonUtil.formatFloat(adMinAmt[j/7], true);
					if(adMinAmt[j/7] == 0d)
						strTemp = "--";
				%>				
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>				
				<%}%>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%></td>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dHalfMonth, true)%></td>
				<%
					if(dTotal > dHalfMonth)
						dGross = dHalfMonth;
					else
						dGross = dTotal;
					strTemp = CommonUtil.formatFloat(dGross, true);
				%>
        <td align="right" class="thinborder"><%=strTemp%></td>
				<%
					
				%>
        <td align="right" class="thinborder"><%=dTax%></td>
				<%
				dNet =  dGross - dTax;
				%>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dNet, true)%></td>
        </tr>
      <%}%>
    </table></td>
  </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td align="right">&nbsp;</td>
    <td>A. CERTIFIED BY : </td>
		<%
			strTemp = WI.fillTextValue("certified_by_a");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"Chief, Administrative Division",7);			
		%>
    <td><input type="text" name="certified_by_a" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>DESIGNATION</td>
		<%
			strTemp = WI.fillTextValue("designation_a");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = "Chief, Administrative Division";
		%>
    <td><input type="text" name="designation_a" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>B. CERTIFIED BY : </td>
		<%
			strTemp = WI.fillTextValue("certified_by_b");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"Accountant III",7);			
		%>		
    <td><input type="text" name="certified_by_b" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>DESIGNATION</td>
		<%
			strTemp = WI.fillTextValue("designation_b");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = "Accountant III";
		%>		
    <td><input type="text" name="designation_b" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>C. APPROVED FOR PAYMENT </td>
		<%
			strTemp = WI.fillTextValue("certified_by_c");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"Director III",7);			
		%>			
    <td><input type="text" name="certified_by_c" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>DESIGNATION</td>
		<%
			strTemp = WI.fillTextValue("designation_c");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = "Director III";
		%>			
    <td><input type="text" name="designation_c" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>D. CERTIFIED BY : </td>
		<%
			strTemp = WI.fillTextValue("certified_by_d");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"Cashier III",7);			
		%>			
    <td><input type="text" name="certified_by_d" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td width="4%" align="right">&nbsp;</td>
    <td width="23%">DESIGNATION</td>
		<%
			strTemp = WI.fillTextValue("designation_d");
			if(strTemp == null || strTemp.length() == 0)
				strTemp = "Cashier III";
		%>					
    <td width="73%"><input type="text" name="designation_d" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td colspan="3" align="right"><font size="2">Number of Employees / rows Per 
        Page :</font><font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
  </tr>
</table>
<% }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="print_page">
	<input type="hidden" name="proceed_" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>