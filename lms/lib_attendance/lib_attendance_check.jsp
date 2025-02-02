<%@ page language="java" import="utility.*,java.util.Date,lms.LibraryAttendance,java.util.Vector" buffer="16kb"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Library Attendance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META HTTP-EQUIV="REFRESH" CONTENT="300; URL=./lib_attendance_check.jsp" >
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
var iFocusCount = 0;
var iTime = <%=new Date().getTime()%>;
	
function focusOnID()
{
	document.form_.stud_id.focus();
	iFocusCount = 0;
}
function JSClock() 
{	++iFocusCount;
	if(iFocusCount >=30)
	{
		<%
		 if (request.getParameter("stud_id") != null && request.getParameter("stud_id").trim().length() > 0) 
		 {%>
			this.ClearPage();
		<%}%>
	} 
   var serverTime = new Date(iTime);
   var hour = serverTime.getHours()
   var minute = serverTime.getMinutes()
   var second = serverTime.getSeconds()
   var temp = "" + ((hour > 12) ? hour - 12 : hour)
   if (hour == 0)
      temp = "12";
   temp += ((minute < 10) ? ":0" : ":") + minute
   temp += ((second < 10) ? ":0" : ":") + second
   temp += (hour >= 12) ? " P.M." : " A.M."

   document.form_.dispClk.value=temp;
   iTime += 1000;

   window.setTimeout("JSClock()", 1000);
}
function ClearPage()
{
	location = "./lib_attendance_check.jsp";
}
function AddRecord()
{
	document.form_.addRecord.value = "1";
}
</script>

<body bgcolor="#009933" topmargin="3" onLoad="JSClock();focusOnID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	
	String strImgFileExt = null;
	String strRootPath = null;//very important for file method.
	String strErrMsg = null;boolean bolFatalErr = false;
	String strTemp = null;
	String strHeight = null;
	
	String[] astrSchoolYrInfo = null;
	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr","9th Yr"};
	
	int i = 0; 
	
//add security here.
	try
	{
//		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
	//							"Admin/staff-System Administrator-IP FILTER","ip_filter.jsp");
		dbOP = new DBOperation();
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.

//IP filter authentication added here.
//CHECK IF THIS IP IS ASSIGNED FOR LOGIN TERMINAL.
strTemp = dbOP.mapOneToOther("LMS_LOGIN_TERMINAL","IP_ADDR","'"+request.getRemoteAddr()+"'",
                          "LOGIN_TERM_INDEX"," and is_valid = 1");
if(strTemp == null) {
	strErrMsg = "IP : "+request.getRemoteAddr()+" IS NOT ASSINGED FOR LOGIN TERMINAL";
	bolFatalErr = true;
}
//end of authenticaion code.
LibraryAttendance libAtt = new LibraryAttendance();
Vector vRetResult = null;
Vector vStudInfo  = null;
Vector vBookIssueInfo = null;

String strIDEntered = WI.fillTextValue("stud_id").toUpperCase();
boolean bolIsAccessionNo = false;

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = dbOP.getSchoolIndex();
	
if(strErrMsg == null) {
	if(WI.fillTextValue("addRecord").compareTo("1") ==0 && WI.fillTextValue("stud_id").length() > 0) {
		vRetResult = libAtt.recordAttendance(dbOP, request, true);
		if(vRetResult == null) {
			strErrMsg = libAtt.getErrMsg();
		}
		else {
			vStudInfo = (Vector)vRetResult.elementAt(0);
			vBookIssueInfo = (Vector)vRetResult.elementAt(1);
			if(vBookIssueInfo == null)
				strErrMsg = libAtt.getErrMsg();
			//if user is blocked, i have to show in message window.
			if(vStudInfo != null && vStudInfo.elementAt(15) != null)
				strErrMsg = "<font style='font-size:80px'>ACCESS <br>&nbsp;&nbsp;&nbsp;BLOCKED</font>";
		}
	}
	
}//only if strErrMsg == null;
	
	if(	vStudInfo != null && vStudInfo.size() > 0) {
		strIDEntered = ((String)vStudInfo.elementAt(1)).toUpperCase();	
		//if(!strIDEntered.equals(WI.fillTextValue("stud_id").toUpperCase())) -- old way.
		bolIsAccessionNo = !((Boolean)vRetResult.elementAt(2)).booleanValue();
			//bolIsAccessionNo = true;
	}
	if (strIDEntered.length() > 0)
	{//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		//java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);//System.out.println(file.getPath());
		//if(file.exists()) {
			strTemp = "../../upload_img/"+strIDEntered+"."+strImgFileExt;
			strTemp = "<img src=\""+strTemp+"\" width=350 height=350 border=2>"; 
		//}
		//else	
		//	strTemp = "<img src=\"../../images/no_pict_esc.jpg\" width=400 height=400 border=2>";
		strHeight = "";
	}
	else
	{
		strTemp = 
		"<img src=\"../../images/logo/"+strSchoolCode+".gif\" width=350 height=350 border=1>";
		strHeight = "";
	}//System.out.println(strTemp);
	
astrSchoolYrInfo = dbOP.getCurSchYr();
if(astrSchoolYrInfo == null) {
	strErrMsg = "School year not set";
	bolFatalErr = true;
}

if(bolFatalErr){
	dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3" color="#FFFF00">
		<strong><%=strErrMsg%></strong></font></p>
<%
	return;
}%>

<form name="form_" method="post" action="./lib_attendance_check.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="30%" valign="top"><br>
  		<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  		<tr><td><%=strTemp%></td></tr>
			<tr>
				<td><br>
<%if(vBookIssueInfo != null) {
String strBGColor = null;
%>
			Overdue books are in red color
			<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
                <tr bgcolor="#FFFFAA"> 
                  <td width="43%" height="20" align="center" class="thinborder"><strong>ACCESSION #</strong></td>
                  <td width="25%" align="center" class="thinborder"><strong>ISSUED ON</strong></td>
                  <td width="32%" align="center" class="thinborder"><strong>DUE ON </strong></td>
                </tr>
<%for(int p = 1; p < vBookIssueInfo.size() ; p += 21) {
/*
   * and for check out verification. - mostly used in library attendance.
   * [0] = Total Overdue book.
   * [0] = book index, [1] = is_overdue(0 = no, 1 = yes, 2 = today / now should be returned.)
   * [2] = book accession number, [3] = book title, [4] = issue date, [5], issue time.
   * [6] = return date, [7] = return time(only if < 24) else null..
   * [8] = reserved_by = patron's ID.
   * [9] = res_priority.
   * 
*/
if( ((String)vBookIssueInfo.elementAt(p + 1)).compareTo("1") == 0)
	strBGColor = " bgcolor=red";
else if( ((String)vBookIssueInfo.elementAt(p + 1)).compareTo("2") == 0)
	strBGColor = " bgcolor=#666666";
else
	strBGColor = "";
%>
                <tr<%=strBGColor%>> 
                  <td height="20" align="center" class="thinborder"><font color="#FFFFAA"><%=(String)vBookIssueInfo.elementAt(p + 2)%></font></td>
                  <td height="20" align="center" class="thinborder"><font color="#FFFFAA"><%=(String)vBookIssueInfo.elementAt(p + 4)%></font></td>
                  <td height="20" align="center" class="thinborder"><font color="#FFFFAA"><%=(String)vBookIssueInfo.elementAt(p + 6)%>
				  <%if(vBookIssueInfo.elementAt(p + 7) != null) {%><%=(String)vBookIssueInfo.elementAt(p + 7)%><%}%></font></td>
                </tr>
<%}%>
              </table>
<%}%>
					
		  		</td>
			</tr>
	    </table>
	  </td>
      <td width="5%" valign="top">&nbsp;</td>
      <td width="65%" colspan="2" valign="top"><br>
  		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td colspan="2"> <div align="center"><font color="#FFFFFF" size="4"><strong> 
                <!--VIRGEN MILAGROSA UNIVERSITY FOUNDATION-->
                <%=utility.SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></div></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2"> 
                <!--Martin P. Posadas Ave., San Carlos City, Pangasinan -->
                <%=utility.SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="3"><strong>(<%=astrSchoolYrInfo[0]%> - <%=astrSchoolYrInfo[1]%>, <%=astrConvertSem[Integer.parseInt(astrSchoolYrInfo[2])]%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><hr size="1" color="#0000FF"></td>
          </tr>
          <tr> 
            <td width="54%" height="25"><font color="#FFFFFF" size="3"><strong> 
			<%if(WI.fillTextValue("stud_id").length() > 0){%>
			<%if(bolIsAccessionNo){%>ACCN. #<%=WI.fillTextValue("stud_id")%><%}else{%>Library ID :<%=strIDEntered%><%}%><%}%></strong></font></td>
            <td width="46%" height="25"><font color="#FFFFFF" size="3">
			<%if(vStudInfo != null && vStudInfo.size() > 0){%>
			Patron Type : <strong><%=WI.getStrValue(vStudInfo.elementAt(5),"Not Set")%></strong><%}%></font></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><font color="#FFFFFF" size="3">
			<%if(vStudInfo != null && vStudInfo.size() > 0){%>
              Name : <strong><%=WebInterface.formatName((String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			(String)vStudInfo.elementAt(4),4)%></strong> 
              <%if(bolIsAccessionNo){%>(<%=(String)vStudInfo.elementAt(1)%>)
			   <%}//show ID in ()
			  }//show name.%>
			</font></td>
          </tr>
<%if(vStudInfo != null && vStudInfo.size() > 0 && ((String)vStudInfo.elementAt(0)).compareTo("1") == 0){%>
          <tr> 
            <td height="25" colspan="2"><font color="#FFFFFF" size="3"> Course 
              : <strong><%=(String)vStudInfo.elementAt(6)%></strong> </font></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><font color="#FFFFFF" size="3"> Major 
              : <strong><%=WI.getStrValue(vStudInfo.elementAt(7),"N/A")%></strong> </font></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><font color="#FFFFFF" size="3"> Year Level: 
              <strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(8),"0"))]%></strong> </font></td>
          </tr>
<%}//end of student -- start of employee.
else if(vStudInfo != null && vStudInfo.size() > 0 && ((String)vStudInfo.elementAt(0)).compareTo("0") == 0){%>		  
          <tr> 
            <td height="25" colspan="2"><font color="#FFFFFF" size="3"> College/Dept. 
              :<strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%></strong> </font></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><font color="#FFFFFF" size="3"> Office 
              :<strong><%=WI.getStrValue(vStudInfo.elementAt(7),"N/A")%></strong> </font></td>
          </tr>
<%}//end of displaying employee%>		  
          <tr> 
            <td height="25" colspan="2">
			<%if(vStudInfo != null && vStudInfo.size() > 0){%>
			<hr size="1" color="#0000FF"><%}%></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><div align="center"><font color="#FFFFFF"><strong><font size="5"> 
                ID<strong>/</strong>LIB. ID/ BOOK ACC. NO. : </font><br>
                <input name="stud_id"  type="text" size="32" class="textbox"  
		  style="font-size:25;color='#FFFF66';" onFocus="style.backgroundColor='#009933'" onBlur="style.backgroundColor='white'">
                </strong></font></div></td>
          </tr>
          <tr> 
            <td height="25" colspan="2" valign="bottom"><div align="center"> </div>
              <hr size="1" color="#0000FF"></td>
          </tr>
          <tr> 
            <td height="40" colspan="2" valign="top"> <font color="#FFFF66" size="4"> 
              <%if(strErrMsg != null){%>
              Message: <%=strErrMsg%></font> <%}%></td>
          </tr>
          <%if(strErrMsg != null){%>
          <tr> 
            <td height="13" colspan="2" valign="top"> <hr size="1" color="#0000FF"> </td>
          </tr>
          <%}%>
          <tr> 
            <td height="13" colspan="2" valign="top"><div align="center"> 
                <input type=text name="dispClk" size="15"  readonly="yes"
				style="border: 0;Color='#ffffff';
				 font-size:60;background-color: #009933;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
              </div></td>
          </tr>
        </table>
	 
	</td>
	</tr>
</table>

<%if(astrSchoolYrInfo != null){%>
<input type="hidden" name="sy_from" value="<%=astrSchoolYrInfo[0]%>">
<input type="hidden" name="sy_to" value="<%=astrSchoolYrInfo[1]%>">
<input type="hidden" name="semester" value="<%=astrSchoolYrInfo[2]%>">
<%}%>

<input type="image" src="../../images/hidden_btn.gif" onClick="AddRecord();"> 
<input type="hidden" name="addRecord">
</form>


</body>
</html>
<% 	
dbOP.cleanUP(); 
%>
