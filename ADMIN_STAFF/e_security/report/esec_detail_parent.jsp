<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strReportToDisp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Campus Query","esec_detail_parent.jsp");
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
														"eSecurity Check","STUDENTS CAMPUS ATTENDANCE QUERY",request.getRemoteAddr(), 
														"esec_detail_parent.jsp");	
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Login ID","Lastname","Firstname"};
String[] astrSortByVal     = {"login_id","lname","fname"};

//String[] astrSortByName = {"Employee ID","Lastname","Firstname", "College", "Department"};
//String[] astrSortByVal  = {"id_number","lname","fname", "college.c_code","department.d_code"};
//if(!bolIsSchool) {
//	astrSortByName[3] = "Division";
//}




boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
boolean bolShowTimeInOut = WI.fillTextValue("show_time").equals("1");

int iSearchResult = 0;
CampusQuery CQ = new CampusQuery(request);
if(WI.fillTextValue("search_page").compareTo("1") == 0){
	vRetResult = CQ.getAttendanceDetailParent(dbOP,request);
	if(vRetResult == null)
		strErrMsg = CQ.getErrMsg();
}
//System.out.println(vRetResult);
strReportToDisp = "PARENT ATTENDANCE REPORT ";//WI.fillTextValue("report_name").toUpperCase();
if(WI.fillTextValue("date_fr").length() > 0)
	strReportToDisp += " AS OF DATE: "+WI.fillTextValue("date_fr");
if(WI.fillTextValue("date_to").length() > 0)
	strReportToDisp += " to "+WI.fillTextValue("date_to");
if(WI.fillTextValue("hr_fr").length() > 0 && WI.fillTextValue("hr_to").length() > 0) {
	double dTimeFr = Double.parseDouble(WI.fillTextValue("hr_fr")) + Double.parseDouble(WI.getStrValue(WI.fillTextValue("min_fr"), "0"))/60d;
	double dTimeTo = Double.parseDouble(WI.fillTextValue("hr_to")) + Double.parseDouble(WI.getStrValue(WI.fillTextValue("min_to"), "0"))/60d;
	strReportToDisp += "<br> Time: "+CommonUtil.convert24HRTo12Hr(dTimeFr)+" - "+CommonUtil.convert24HRTo12Hr(dTimeTo);
}

%>	
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
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.search_page.value = "";
	document.form_.submit();
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	var obj = document.getElementById('myADTable2');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);

	//3rd table is conditional.. 
	obj = document.getElementById('myADTable3');
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		--iRowCount;
		obj.deleteRow(0);
	}
	alert("Click OK to Print.");
	window.print();
}
</script>
<body>
<form action="./esec_detail_parent.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td width="88%" height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PARENT CAMPUS ATTENDANCE QUERY PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr > 
      <td height="25" width="3%">&nbsp;</td>
      <td width="12%">DATE :</td>
      <td colspan="2" width="85%" style="font-size:9px;"> <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a> to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a>

		&nbsp;&nbsp;&nbsp;
<%
String[] astrHR = {"12AM","1AM","2AM","3AM","4AM","5AM","6AM","7AM","8AM","9AM","10AM","11AM","12PM",
					"1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM","10PM",	"11PM"};
String[] astrMM = {"00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19",
				   "20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39",	
				   "40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"};	
strTemp = WI.fillTextValue("hr_fr");
int iDefVal = -1;
if(strTemp.length() > 0) 
	iDefVal = Integer.parseInt(strTemp);
%>
		Time (optional): <select name="hr_fr">
		<option value=""></option>
		<%for(int i = 0; i < 24; ++i) {
			if(iDefVal == i)
				strTemp = "selected";
			else	
				strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=astrHR[i]%></option>
		<%}%>
		</select> : 
<%
strTemp = WI.fillTextValue("min_fr");
iDefVal = -1;
if(strTemp.length() > 0) 
	iDefVal = Integer.parseInt(strTemp);
%>
		<select name="min_fr">
		<option value=""></option>
		<%for(int i = 0; i < 60; i+= 5) {
			if(iDefVal == i)
				strTemp = "selected";
			else	
				strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=astrMM[i]%></option>
		<%}%>
		</select>
		
		- 
<%
strTemp = WI.fillTextValue("hr_to");
iDefVal = -1;
if(strTemp.length() > 0) 
	iDefVal = Integer.parseInt(strTemp);
%>
		<select name="hr_to">
		<option value=""></option>
		<%for(int i = 0; i < 24; ++i) {
			if(iDefVal == i)
				strTemp = "selected";
			else	
				strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=astrHR[i]%></option>
		<%}%>
		</select> : 
<%
strTemp = WI.fillTextValue("min_to");
iDefVal = -1;
if(strTemp.length() > 0) 
	iDefVal = Integer.parseInt(strTemp);
%>
		<select name="min_to">
		<option value=""></option>
		<%for(int i = 0; i < 60; i+= 5) {
			if(iDefVal == i)
				strTemp = "selected";
			else	
				strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=astrMM[i]%></option>
		<%}%>
		</select>
		
				
		</td>
    </tr>

	<tr > 
      <td height="25">&nbsp;</td>
      <td>LOC :</td>
      <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
	  <select name="loc_index"> 
	  <option value=""> ALL LOCATIONS </option>
	  	<%=dbOP.loadCombo("LOCATION_INDEX","LOC_NAME",
			" from ESC_LOGIN_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%>
 	 </select>	 
	 
	 &nbsp;&nbsp;&nbsp;
<%
strTemp = WI.fillTextValue("show_time");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>	 
	 <input type="checkbox" name="show_time" value="1" <%=strTemp%>> Show Time in/out record.	  </td>
    </tr>
	<tr >
	  <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
	<tr >
	  <td height="25" width="3%">&nbsp;</td>
	  <td width="12%">Login ID </td>
	  <td width="85%">
	  <select name="id_number_con" style="font-size:11px">
          <%=CQ.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%>
        </select> 
	  <input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td>Last Name </td>
	  <td>
	  <select name="lname_con" style="font-size:11px">
          <%=CQ.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
	  <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td>First Name </td>
	  <td>
	  <select name="fname_con" style="font-size:11px">
          <%=CQ.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
	  <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%if(!bolIsBasic && false){%>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
	  <td><select name="college" onChange="ReloadPage();">
        <option value=""></option>
        <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name", request.getParameter("college"), false)%>
      </select></td>
	</tr>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td>Office/Department</td>
	  <td><select name="course_index" onChange="ReloadPage();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
		  								WI.getStrValue(WI.fillTextValue("college"), " and c_index=", "", "")+
 										" order by course_name asc", request.getParameter("course_index"), false)%>
      </select></td>
    </tr>
<%}else{%>
<%}%>
	<tr >
	  <td height="25">&nbsp;</td>
	  <td>SORT BY </td>
	  <td>
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=CQ.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0)
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="desc" <%=strTemp%>>Desc</option>
        </select>
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=CQ.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0)
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="desc" <%=strTemp%>>Desc</option>
        </select>
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=CQ.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0)
	strTemp = " selected";
else	
	strTemp = "";
%>
		  <option value="desc" <%=strTemp%>>Desc</option>
        </select>	  </td>
    </tr>	
    <tr > 
	
      <td height="10">&nbsp;</td>
      <td colspan="2" align="center" style="font-size:9px;">
	  Number of  rows per page : 
	    <select name="max_lines" style="font-size:10px;">
	  <% 
	  	strTemp = WI.fillTextValue("max_lines");
		if(strTemp.length() == 0) 
			strTemp = "40";
			
	  	for (int i =20; i <= 40; ++i){ 
		 if (strTemp.equals(Integer.toString(i))){
		  %>
		   <option selected><%=i%></option>	
		   <%}else{%>
		   <option><%=i%></option>		   
		  <%}
	  	} // end for loop%>
	  	</select>	  

	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  
      <input type="submit" name="12" value="Search Attendance" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.search_page.value='1'">	  </td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr > 
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a><font size="1">click 
          to print listing/report</font></div></td>
    </tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" align="center">
		<font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        	<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        	<%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
			<%=strReportToDisp%>
		</font>
	  </td>
    </tr>
  </table>
  <!--<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25">Total Result : <%=vRetResult.size()/7%></td>
      <td width="34%">&nbsp; </td>
    </tr>
  </table>-->
<%
Vector vTimeInOut = null;

int iMaxRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_lines"), "40"));
int iRowCount = 0; int i = 0; int iCount = 0; 

while(i < vRetResult.size()) {
if(iRowCount >= iMaxRowsPerPage) {
	iRowCount = 0;
	%>
 <DIV style="page-break-before:always">&nbsp;</DIV> 
<%}%> 
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold;" bgcolor="#EEEEEE"> 
      <td width="3%" height="22" align="center" class="thinborder">Count</td>
      <td width="12%" align="center" class="thinborder">Login ID </td>
      <td width="18%" align="center" class="thinborder">Parent Name </td>
      <%if(false){%><td width="20%" align="center" class="thinborder"><%if(bolIsSchool){%>College<%}else{%>Division/Office<%}%></td><%}%>
      <%if(bolShowTimeInOut){%>
      <td width="47%" align="center" class="thinborder">TimeIn/Out Record</td>
<%}%>
    </tr>
<%for(; i< vRetResult.size(); i +=6){
if(iRowCount >= iMaxRowsPerPage)
	break;
++iRowCount; ++iCount;
strTemp = (String)vRetResult.elementAt(i + 3);
if(vRetResult.elementAt(i + 4) != null)
	strTemp = WI.getStrValue(strTemp,"-") + "/"+vRetResult.elementAt(i + 4);
%>
    <tr> 
      <td height="25" class="thinborder"><%=iCount%>. </td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <%if(false){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
<%if(bolShowTimeInOut){
vTimeInOut = (Vector) vRetResult.elementAt(i + 5);
if(vTimeInOut == null)
	vTimeInOut = new Vector();
strTemp = WI.getStrValue((String)vTimeInOut.remove(0),"",": ","")+vTimeInOut.remove(0);
while(vTimeInOut.size() > 0) {
	strTemp += "<br>" + WI.getStrValue((String)vTimeInOut.remove(0),"",": ","")+vTimeInOut.remove(0);
	++iRowCount;
}
%>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%}%>
   </tr>
<%}%>
  </table>
<%}//end of while condition to put page break%>

<%}//only if vRetResult is not null %>
 <input type="hidden" name="search_page"> 
<input type="hidden" name="report_to_disp" value="<%=strReportToDisp%>">
<input type="hidden" name="print_pg">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>