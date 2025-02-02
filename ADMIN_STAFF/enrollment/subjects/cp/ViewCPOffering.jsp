<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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

SubjectSection SS = new SubjectSection();
Vector vRetResult = null;
String[] astrConvertTerm = {"SUMMER","1ST","2ND","3RD"}; 

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";



/**
String strCourseI = WI.fillTextValue("course_index");
String strMajorI  = WI.fillTextValue("major_index");
String strYrLevel = WI.fillTextValue("year_level");
String strSection = WI.fillTextValue("section");
**/
String strCourse = null;
String strMajor  = null;
String strYrLevel = null;
String strCollege = null;

String strSection = WI.fillTextValue("section");


Vector vCourse = null;
Vector vMajor  = null;

vRetResult = SS.getOneSectionOfferDetail(dbOP, request);
if(vRetResult == null)
	strErrMsg = SS.getErrMsg();
else {
	vCourse = (Vector)vRetResult.remove(0);
	vMajor  = (Vector)vRetResult.remove(0);
}


//System.out.println(vRetResult);

dbOP.cleanUP();

if(strErrMsg != null){%>
	<p align="center" style="font-weight:bold; color:#FF0000; font-size:14px;"><%=strErrMsg%></p>
<%return;}


Vector vRoomSch = null;
int iIndexOf = 0;

double dTimeFr = 0d;
double dTimeTo = 0d;

int iWeekDay   = 0;
String strSubCode = null;
String strRoomNo  = null;
String strIsLec   = null;

boolean bolShowMWF = WI.fillTextValue("show_mwf").equals("1");

Vector vTimeSch = new Vector(); String strMWF = null;

String[] astrConvertWeekDay = {"Sunday","M","T","W","TH","F","S"};
String[] strConvertAMPM     = {"AM","PM"};

for(int i = 0; i < vRetResult.size(); i += 6) {

	vRoomSch = (Vector)vRetResult.elementAt(i + 5);
	iIndexOf = vCourse.indexOf(vRetResult.elementAt(i));
	
	strCourse = null;
	strCollege = null;
	
	if(iIndexOf > -1) {
		strCourse  = (String)vCourse.elementAt(iIndexOf + 2);
		strCollege = (String)vCourse.elementAt(iIndexOf + 3);
	}
if(strSchCode.startsWith("CIT")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="6%"><img src="../../../../images/logo/CIT_CEBU.gif" height="50" width="50"></td>
	  	<td width="1%">&nbsp;</td>
		<td width="93%">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr style="font-weight:bold">
					<td >CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY <BR>
					<font style="font-weight:normal; font-size:9px;">N. Bacalso Avenue, Cebu City</font>					</td>
					<td>SCHEDULE OF CLASSES</td>
				</tr>
				<tr style="font-weight:bold">
				  <td colspan="2"><hr></td>
			  </tr>
			</table>	  </td>
	</tr>
  </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="70%" style="font-weight:bold">&nbsp;</td>
		<td width="30%" style="font-weight:bold">SCHEDULE OF CLASSES</td>
	</tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td style="font-weight:bold" width="10%">COLLEGE</td>
		<td width="60%"><%=WI.getStrValue(strCollege)%></td>
		<td style="font-weight:bold" width="10%">SY-TERM</td>
		<td width="20%"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to").substring(2)%></td>
	</tr>
	<tr>
	  <td style="font-weight:bold">COURSE</td>
	  <td><%=WI.getStrValue(strCourse)%></td>
	  <td style="font-weight:bold">&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td style="font-weight:bold">CURR.YR</td>
	  <td><%=vRetResult.elementAt(i + 2)%> - <%=vRetResult.elementAt(i + 3)%></td>
	  <td style="font-weight:bold">YR &amp; SEC. </td>
	  <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"N/A")%> - <%=strSection%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td width="21%" class="thinborder">Sub Code</td>
			<td width="79%" class="thinborder">Schedule</td>
		</tr>
		<%while(vRoomSch.size() > 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));

		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);

		%>
		<tr>
			<td width="21%" class="thinborder"><%=strSubCode%></td>
			<td width="79%" class="thinborder">
			<%
			vTimeSch = new Vector(); strMWF = "";
			while(vRoomSch.size() > 0 && vRoomSch.elementAt(11).equals(strSubCode)) {
				if(!bolShowMWF) {
					iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
					strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
					if(strMWF.length() > 0)
						strMWF = strMWF + "<br>";
					strMWF += strRoomNo+" &nbsp;"+astrConvertWeekDay[iWeekDay] + "&nbsp;"+
					(String)vRoomSch.elementAt(1)+":"+(String)vRoomSch.elementAt(2)+"&nbsp;"+
					strConvertAMPM[Integer.parseInt((String)vRoomSch.elementAt(3))]+" to "+
					(String)vRoomSch.elementAt(4)+":"+(String)vRoomSch.elementAt(5)+"&nbsp;"+
					strConvertAMPM[Integer.parseInt((String)vRoomSch.elementAt(6))];
					
					vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
					continue;					
				}
				else if(strRoomNo.equals(WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;"))) {
					//do nothing..
				}
				else {
					if(strMWF.length() > 0)
						strMWF = strMWF + "<br>";
					strTemp = ConversionTable.convertMWFFormat(vTimeSch);
					
					iIndexOf = strTemp.indexOf(" ");
					if(iIndexOf > -1)
						strTemp = strTemp.substring(iIndexOf).toLowerCase() +  " &nbsp;" + strTemp.substring(0, iIndexOf);
					
					strMWF = strMWF +strTemp + "&nbsp;"+ strRoomNo;

					
					
					strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
					vTimeSch = new Vector();
				}
				vTimeSch.addElement((String)vRoomSch.elementAt(0));//weekday
				vTimeSch.addElement((String)vRoomSch.elementAt(1));//hour_from
				vTimeSch.addElement((String)vRoomSch.elementAt(2));//minute_from
				vTimeSch.addElement((String)vRoomSch.elementAt(3));//ampm_from
				vTimeSch.addElement((String)vRoomSch.elementAt(4));//hour_to
				vTimeSch.addElement((String)vRoomSch.elementAt(5));//minute_to
				vTimeSch.addElement((String)vRoomSch.elementAt(6));//ampm_to
				
				vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
			}
			if(vTimeSch.size() > 0) {
				strTemp = ConversionTable.convertMWFFormat(vTimeSch);
					
				iIndexOf = strTemp.indexOf(" ");
				if(iIndexOf > -1)
					strTemp = strTemp.substring(iIndexOf).toLowerCase() +  " &nbsp;" + strTemp.substring(0, iIndexOf);
				if(strMWF.length() > 0)
					strMWF = strMWF + "<br>";
				strMWF = strMWF +strTemp + "&nbsp;"+ strRoomNo;
			}
			%>
			<%=strMWF%>
			
			</td>
		</tr>
		<%}%>
  </table>


<%}%>



</body>
</html>
