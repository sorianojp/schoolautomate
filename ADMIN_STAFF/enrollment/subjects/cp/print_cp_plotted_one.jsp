<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	boolean bolIsBatchPrint = WI.fillTextValue("batch_print").equals("1");

if(!bolIsBatchPrint){%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0' onLoad="window.print()">
<%}

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
String strCourse = null; String strCourseCode = null;
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
//System.out.println(vCourse);
//System.out.println(vMajor);

//vRetResult = null;

dbOP.cleanUP();

if(strErrMsg != null){%>
	<p align="center" style="font-weight:bold; color:#FF0000; font-size:14px;"><%=strErrMsg%></p>
<%return;}


Vector vTimeSch = new Vector();
/**
vTimeSch.addElement("7:30 - 8:30");//vTimeSch.addElement(null);
vTimeSch.addElement("8:30 - 9:30");//vTimeSch.addElement(null);
vTimeSch.addElement("9:30 - 10:30");//vTimeSch.addElement(null);
vTimeSch.addElement("10:30 - 11:30");//vTimeSch.addElement(null);
vTimeSch.addElement("11:30 - 12:30");//vTimeSch.addElement(null);
vTimeSch.addElement("12:30 - 1:30");//vTimeSch.addElement(null);
vTimeSch.addElement("1:30 - 2:30");//vTimeSch.addElement(null);
vTimeSch.addElement("2:30 - 3:30");//vTimeSch.addElement(null);
vTimeSch.addElement("3:30 - 4:30");//vTimeSch.addElement(null);
vTimeSch.addElement("4:30 - 5:30");//vTimeSch.addElement(null);
vTimeSch.addElement("5:30 - 6:30");//vTimeSch.addElement(null);
vTimeSch.addElement("6:30 - 7:30");//vTimeSch.addElement(null);
vTimeSch.addElement("7:30 - 8:30");//vTimeSch.addElement(null);
vTimeSch.addElement("8:30 - 9:00");
**/
vTimeSch.addElement("7:00 - 7:30");vTimeSch.addElement("7:30 - 8:00");
vTimeSch.addElement("8:00 - 8:30");vTimeSch.addElement("8:30 - 9:00");
vTimeSch.addElement("9:00 - 9:30");vTimeSch.addElement("9:30 - 10:00");
vTimeSch.addElement("10:00 - 10:30");vTimeSch.addElement("10:30 - 11:00");
vTimeSch.addElement("11:00 - 11:30");vTimeSch.addElement("11:30 - 12:00");
vTimeSch.addElement("12:00 - 12:30");vTimeSch.addElement("12:30 - 1:00");
vTimeSch.addElement("1:00 - 1:30");vTimeSch.addElement("1:30 - 2:00");
vTimeSch.addElement("2:00 - 2:30");vTimeSch.addElement("2:30 - 3:00");
vTimeSch.addElement("3:00 - 3:30");vTimeSch.addElement("3:30 - 4:00");
vTimeSch.addElement("4:00 - 4:30");vTimeSch.addElement("4:30 - 5:00");
vTimeSch.addElement("5:00 - 5:30");vTimeSch.addElement("5:30 - 6:00");
vTimeSch.addElement("6:00 - 6:30");vTimeSch.addElement("6:30 - 7:00");
vTimeSch.addElement("7:00 - 7:30");vTimeSch.addElement("7:30 - 8:00");
vTimeSch.addElement("8:00 - 8:30");vTimeSch.addElement("8:30 - 9:00");
//vTimeSch.addElement("9:00 - 9:30");vTimeSch.addElement("9:30 - 10:00");





Vector vRoomSch = null;
int iIndexOf = 0;

double dStartTime = 6.5d;
double dTimeFr = 0d;
double dTimeTo = 0d;
double dDiff   = 0d;

int iRowSpan   = 0; 
String strRowSpan = null;

String strRowSpanM  = null; String strValM  = null;
String strRowSpanT  = null; String strValT  = null;
String strRowSpanW  = null; String strValW  = null;
String strRowSpanTH = null; String strValTH = null;
String strRowSpanF  = null; String strValF  = null;
String strRowSpanS  = null; String strValS  = null;
String strRowSpanSU = null; String strValSU = null;

int iRowSpanM  = 0;
int iRowSpanT  = 0;
int iRowSpanW  = 0;
int iRowSpanTH = 0;
int iRowSpanF  = 0;
int iRowSpanS  = 0;
int iRowSpanSU = 0;

boolean bolIsUsed = true;



int iWeekDay   = 0;
String strSubCode = null;
String strRoomNo  = null;
String strIsLec   = null;

for(int i = 0; i < vRetResult.size(); i += 6) {
if(i > 0) {%>
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}

dStartTime = 6.5d;
 strRowSpanM  = null;  strValM  = null;
 strRowSpanT  = null;  strValT  = null;
 strRowSpanW  = null;  strValW  = null;
 strRowSpanTH = null;  strValTH = null;
 strRowSpanF  = null;  strValF  = null;
 strRowSpanS  = null;  strValS  = null;
 strRowSpanSU = null;  strValSU = null;


	vRoomSch = (Vector)vRetResult.elementAt(i + 5);
	iIndexOf = vCourse.indexOf(vRetResult.elementAt(i));
	
	strCourse = null;
	strCollege = null;
	
	if(iIndexOf > -1) {
		strCourse  = (String)vCourse.elementAt(iIndexOf + 2);
		strCollege = (String)vCourse.elementAt(iIndexOf + 3);
		strCourseCode = (String)vCourse.elementAt(iIndexOf + 1);
	}
	if(vMajor != null && vMajor.size() > 0) {
		iIndexOf = vMajor.indexOf(vRetResult.elementAt(i + 1));
		if(iIndexOf > -1) {
			strCourse  = strCourseCode + " - "+(String)vMajor.elementAt(iIndexOf + 2);
		}

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
		<td width="20%"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to").substring(2)%></td>
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
	  <tr style="font-weight:bold" align="center">
		<td width="12%" class="thinborder" height="24" align="center">TIME</td>
		<td width="12%" class="thinborder">MON</td>
		<td width="12%" class="thinborder">TUE</td>
		<td width="12%" class="thinborder">WED</td>
		<td width="12%" class="thinborder">THURS</td>
		<td width="12%" class="thinborder">FRI</td>
		<td width="12%" class="thinborder">SAT</td>
		<td width="12%" class="thinborder">SUN</td>
	  </tr>
	  <%
for(int p = 0; p < vTimeSch.size(); ++p) {
dStartTime += 0.5d;
 strRowSpanM  = null;  strValM  = null;
 strRowSpanT  = null;  strValT  = null;
 strRowSpanW  = null;  strValW  = null;
 strRowSpanTH = null;  strValTH = null;
 strRowSpanF  = null;  strValF  = null;
 strRowSpanS  = null;  strValS  = null;
 strRowSpanSU = null;  strValSU = null;

%>
	  <tr align="center">
	  	<%if(vTimeSch.elementAt(p) != null){
			/**
			if(!SS.bolIsSchedExist(dStartTime, 1, vRoomSch)) {
				//iRowSpanM = 2;
				//strRowSpanM = " rowspan='2'";
				//System.out.println("I am here Week 1 : Time : "+dStartTime);
			}
			if(!SS.bolIsSchedExist(dStartTime, 2, vRoomSch)) {
				//iRowSpanT = 2;
				//strRowSpanT = " rowspan='2'";
				//System.out.println("I am here Week 2 : Time : "+dStartTime);
			}
			if(!SS.bolIsSchedExist(dStartTime, 3, vRoomSch)) {
				//iRowSpanW = 2;
				//strRowSpanW = " rowspan='2'";
				//System.out.println("I am here Week 3 : Time : "+dStartTime);
			}
			if(!SS.bolIsSchedExist(dStartTime, 4, vRoomSch)) {
				//iRowSpanTH = 2;
				//strRowSpanTH = " rowspan='2'";
				//System.out.println("I am here Week 4 : Time : "+dStartTime);
			}
			if(!SS.bolIsSchedExist(dStartTime, 5, vRoomSch)) {
				//iRowSpanF = 2;
				//strRowSpanF = " rowspan='2'";
				//System.out.println("I am here Week 5 : Time : "+dStartTime);
			}
			if(!SS.bolIsSchedExist(dStartTime, 6, vRoomSch)) {
				//iRowSpanS = 2;
				//strRowSpanS = " rowspan='2'";
				//System.out.println("I am here Week 6 : Time : "+dStartTime);
			}**/
		%>
		    <td height="15" <%if(false){%>rowspan="2"<%}%> class="thinborder" style="font-weight:bold"><%=vTimeSch.elementAt(p)%></td>
		<%}%>




<%////////////////Sunday. - have to move to top because sunday = 0
	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 0) {
		strValSU     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanSU >0)
			strValSU = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValSU+"</font>";
		strRowSpanSU = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanSU   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>




<%//////////// monday.
//System.out.println(bolIsUsed);
//System.out.println(vRoomSch.size());

	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 1) {
		strValM     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanM >0)
			strValM = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValM+"</font>";
		strRowSpanM = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanM   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanM != null || iRowSpanM <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanM)%>><%=WI.getStrValue(strValM, "&nbsp;")%></td>
<%
}--iRowSpanM;%>		

<%////////////////tuesday.
	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 2) {
		strValT     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanT >0)
			strValT = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValT+"</font>";
		strRowSpanT = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanT   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanT != null || iRowSpanT <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanT)%>><%=WI.getStrValue(strValT, "&nbsp;")%></td>
<%
}--iRowSpanT;%>		
<%////////////////Wednesday.
	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 3) {
		strValW     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanW >0)
			strValW = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValW+"</font>";
		strRowSpanW = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanW   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanW != null || iRowSpanW <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanW)%>><%=WI.getStrValue(strValW, "&nbsp;")%></td>
<%
}--iRowSpanW;%>		

<%////////////////Thursday.
	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 4) {
		strValTH     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanTH >0)
			strValTH = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValTH+"</font>";
		strRowSpanTH = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanTH   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanTH != null || iRowSpanTH <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanTH)%>><%=WI.getStrValue(strValTH, "&nbsp;")%></td>
<%
}--iRowSpanTH;%>		
<%////////////////Friday.
	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 5) {
		strValF     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanF >0)
			strValF = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValF+"</font>";
		strRowSpanF = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanF   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanF != null || iRowSpanF <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanF)%>><%=WI.getStrValue(strValF, "&nbsp;")%></td>
<%
}--iRowSpanF;%>		
<%////////////////Saturday.
	if(bolIsUsed && vRoomSch.size()> 0) {
		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(0));
		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(7));
		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(8));
		dDiff    = (dTimeTo - dTimeFr + 0.1d)/0.5d;
		
		iRowSpan   = (int)dDiff;
		
		strSubCode = (String)vRoomSch.elementAt(11);
		strRoomNo  = WI.getStrValue((String)vRoomSch.elementAt(9), "&nbsp;");
		strIsLec   = (String)vRoomSch.elementAt(10);
		
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);vRoomSch.remove(0);
		
		bolIsUsed = false;
	}
if(!bolIsUsed && dStartTime == dTimeFr) {
	if(iWeekDay == 6) {
		strValS     = strSubCode + "<br>" +strRoomNo;
		if(iRowSpanS >0)
			strValS = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValS+"</font>";
		strRowSpanS = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanS   = iRowSpan;
		
		bolIsUsed = true;
	}
}
//System.out.println(dStartTime);System.out.println(dTimeFr);System.out.println(iWeekDay);
%>

<%if(strRowSpanS != null || iRowSpanS <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanS)%>><%=WI.getStrValue(strValS, "&nbsp;")%></td>
<%
}--iRowSpanS;%>		

<%if(strRowSpanSU != null || iRowSpanSU <=0){%>
	    <td class="thinborder"<%=WI.getStrValue(strRowSpanSU)%>><%=WI.getStrValue(strValSU, "&nbsp;")%></td>
<%
}--iRowSpanSU;%>		

      </tr>
<%}%>
	  
<!--	  
	  <tr align="center">
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
    </tr>
	  <tr align="center">
	    <td class="thinborder" style="font-weight:bold"><span class="thinborder" style="font-weight:bold">8:30 - 9:00 </span></td>
	    	<td height="24" class="thinborder">&nbsp;
				<%if(dTimeFr == 20.5d && iWeekDay == 1){%><%=strSubCode%> <%=strRoomNo%><%}%>
			</td>
	    	<td height="24" class="thinborder">&nbsp;
				<%if(dTimeFr == 20.5d && iWeekDay == 2){%><%=strSubCode%> <%=strRoomNo%><%}%>
			</td>
	    	<td height="24" class="thinborder">&nbsp;
				<%if(dTimeFr == 20.5d && iWeekDay == 3){%><%=strSubCode%> <%=strRoomNo%><%}%>
			</td>
	    	<td height="24" class="thinborder">&nbsp;
				<%if(dTimeFr == 20.5d && iWeekDay == 4){%><%=strSubCode%> <%=strRoomNo%><%}%>
			</td>
	    	<td height="24" class="thinborder">&nbsp;
				<%if(dTimeFr == 20.5d && iWeekDay == 5){%><%=strSubCode%> <%=strRoomNo%><%}%>
			</td>
	    	<td height="24" class="thinborder">&nbsp;
				<%if(dTimeFr == 20.5d && iWeekDay == 6){%><%=strSubCode%> <%=strRoomNo%><%}%>
			</td>
    </tr>
-->  </table>


<%}%>


<%if(!bolIsBatchPrint){%>
</body>
</html>
<%}%>