<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int i=0; int j=0;
	int iYear = 0;
	int iSem  = 0;
	int iTempYear = 0;
	int iTempSem = 0;

	String[] astrPrepPropInfo = {""," (Preparatory)","(Proper)"};
	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String strResidencyStatus = null;

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
//authenticate this user.
//end of authenticaion code.

GradeSystem GS = new GradeSystem();
if(strStudID != null)
{
	vTemp = GS.getResidencySummary(dbOP,strStudID);
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
}
else
	strErrMsg = "You are logged out by system. Please login again.";


if(strErrMsg == null) strErrMsg = "";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::
        RESIDENCY STATUS ::::</strong></font></div></td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
	  <td height="25" colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>

<%if(vTemp != null && vTemp.size()>0)
{%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="2%" height="25">&nbsp;</td>
    <td width="15%">Course/Major :</td>
    <td colspan="3"><strong><%=(String)vTemp.elementAt(6)%>/<%=WI.getStrValue(vTemp.elementAt(7))%>
      (<%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%>)</strong></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">Status:<strong> </strong></td>
    <td height="25" colspan="2"><strong>
      <%
strResidencyStatus = (String)vTemp.elementAt(14);
if(strResidencyStatus.compareTo("0") ==0)
	strResidencyStatus = "Regular";
else if(strResidencyStatus.compareTo("1") ==0)
	strResidencyStatus = "Irregular";
%>
      &nbsp;<%=strResidencyStatus%></strong></td>
    <td width="28%" height="25"><div align="right"></div></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td height="18"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
    <td height="18"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td width="31%" height="18">&nbsp;</td>
    <td width="24%" height="18">&nbsp;</td>
    <td height="18"><div align="right"></div></td>
  </tr>
  <tr>
    <td  colspan="5" height="21"><hr size="1"></td>
  </tr>
</table>
<%
//check residency status in detail.
String strCourseType = (String)vTemp.elementAt(11);
float fTotalUnits = 0;
float fTotalUnitPerSem = 0;

vTemp = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),strCourseType);
if(vTemp == null)
{%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <td width="2%" height="18">&nbsp;</td>
  <td><%=GS.getErrMsg()%></td>
  </table>
<%}
else {

	if(strCourseType.compareTo("0") ==0)//under graduate
	{%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr bgcolor="#BECED3">
    <td>&nbsp;</td>
    <td width="17%"  height="25"><div align="left"><font size="1"><strong>SUBJECT_CODE</strong></font></div></td>
    <td width="36%"><div align="left"><font size="1"><strong>SUBJECT_DESC</strong></font></div></td>
    <td width="8%"><div align="left"><font size="1"><strong>LEC UNIT</strong></font></div></td>
    <td width="11%"><div align="left"><font size="1"><strong>LAB UNIT</strong></font></div></td>
    <td width="10%"><strong><font size="1">CREDIT EARNED</font></strong></td>
<!--    <td width="10%"><font size="1"><strong>GRADE</strong></font></td>-->
    <td width="16%"><font size="1"><strong>REMARKS</strong></font></td>
  </tr>
  <%
for(i=0 ; i< vTemp.size();){
iYear = Integer.parseInt((String)vTemp.elementAt(i));
iSem = Integer.parseInt((String)vTemp.elementAt(i+1));

%>
  <tr>
    <td width="2%">&nbsp;</td>
    <td colspan="7">&nbsp;</td>
  </tr>
  <tr>
    <td width="2%">&nbsp;</td>
    <td colspan="7"><strong><u><%=iYear%> Year/<%=iSem%> Semester,SY
      <%=(String)vTemp.elementAt(i+10) + " - "+(String)vTemp.elementAt(i+11)%>
      <%=astrPrepPropInfo[Integer.parseInt((String)vTemp.elementAt(i+9))]%></u></strong></td>
  </tr>
  <%
 for(j=i; j< vTemp.size();){//System.out.println(vTemp.elementAt(j+4));System.out.println(vTemp.elementAt(j+5));

	iTempYear = Integer.parseInt((String)vTemp.elementAt(j));
	iTempSem  = Integer.parseInt((String)vTemp.elementAt(j+1));
	//System.out.println(iTempYear);
	//System.out.println(iTempSem);
	//System.out.println(vTemp.size());

	if(iTempYear!= iYear || iTempSem != iSem)
		break;
	//only if remark status is passed.
	if( ((String)vTemp.elementAt(j+7)).compareToIgnoreCase("passed") ==0)
		fTotalUnitPerSem += Float.parseFloat((String)vTemp.elementAt(j+4))+Float.parseFloat((String)vTemp.elementAt(j+5));
	 %>
  <tr>
    <td>&nbsp;</td>
    <td  height="19"><div align="left"><%=(String)vTemp.elementAt(j+2)%></div></td>
    <td><div align="left"><%=(String)vTemp.elementAt(j+3)%></div></td>
    <td><div align="left"><%=(String)vTemp.elementAt(j+4)%></div></td>
    <td><div align="left"><%=(String)vTemp.elementAt(j+5)%></div></td>
    <td align="center"><%=WI.getStrValue(vTemp.elementAt(j+8))%></td>
   <!-- <td><%=(String)vTemp.elementAt(j+6)%></td>-->
    <td><%=(String)vTemp.elementAt(j+7)%></td>
  </tr>
<%if(vTemp.elementAt(j+12) != null){%>
    <tr> 
      <td>&nbsp;</td>
      <td  height="19"></td>
      <td colspan="6"><font size="1"><%=(String)vTemp.elementAt(j+12)%></font></td>
    </tr>
    <%}
	j = j+13;
	i = j;
	}///end of inner loop%>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="8"><div align="center"><em>Total units completed for this semester
        :<strong> <%=fTotalUnitPerSem%></strong></em></div></td>
  </tr>
  <%
fTotalUnits += fTotalUnitPerSem;
fTotalUnitPerSem = 0;
}//end of outer loop %>
  <tr>
    <td height="22" colspan="8">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="8"><strong>TOTAL UNITS FOR THIS COURSE : <u><%=fTotalUnits%></u></strong></td>
  </tr>
</table>
<%}//end of displaying for graduate course.
else if(strCourseType.compareTo("2") ==0)//College of Medicine.
{%>


<table width="100%" border="0" bgcolor="#FFFFFF">
  <tr bgcolor="#BECED3">
    <td>&nbsp;</td>
    <td  height="19" ><font size="1"><strong>SUBJECT CODE</strong></font></td>
    <td colspan="3"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
    <td><font size="1"><strong>TOTAL LOAD</strong></font></td>
    <td><font size="1"><strong>GRADE</strong></font></td>
    <td width="9%"><font size="1"><strong>REMARK</strong></font></td>
  </tr>
  <%
	String strMainSubject = null;
for(i=0 ; i< vTemp.size();){
iYear = Integer.parseInt((String)vTemp.elementAt(i));
iSem = Integer.parseInt((String)vTemp.elementAt(i+1));

%>
  <tr>
    <td align="center">&nbsp;</td>
    <td colspan="7"><strong><u> <%=iYear%> YEAR/<%=iSem%> SEMESTER<strong>,
      SY <%=(String)vTemp.elementAt(i+12) + " - "+(String)vTemp.elementAt(i+13)%></strong></u></strong></td>
  </tr>
  <%
for(j = i ; j< vTemp.size(); ++j)
{
iTempYear = Integer.parseInt((String)vTemp.elementAt(j));
iTempSem = Integer.parseInt((String)vTemp.elementAt(j+1));
if(iTempYear != iYear || iTempSem != iSem) break;

	strMainSubject = (String)vTemp.elementAt(j+2);
%>
  <tr>
    <td align="center"><em></em></td>
    <td align="center"><div align="left"><%=strMainSubject%></div></td>
    <td  colspan="3" align="center"><div align="left"><%=(String)vTemp.elementAt(j+3)%></div></td>
    <td align="center"><div align="left"><%=(String)vTemp.elementAt(j+6)%>-(<%=(String)vTemp.elementAt(j+8)%>)
      </div></td>
    <td align="center"><div align="left"><%=(String)vTemp.elementAt(j+9)%></div></td>
    <td><%=(String)vTemp.elementAt(j+10)%></td>
  </tr>
<%if(vTemp.elementAt(j + 14) != null){%>
    <tr> 
      <td ></td>
      <td></td>
      <td  colspan="6"><font size="1"><%=(String)vTemp.elementAt(j+14)%></font></td>
    </tr>
    <%}
	for(int k = j ; k< vTemp.size();)
	{
	if(strMainSubject.compareTo((String)vTemp.elementAt(k+2)) !=0)
	{
		j = j-15;
		break;
	}
	%>
  <tr>
    <td align="center">&nbsp;</td>
    <td width="17%"  height="21">&nbsp;</td>
    <td colspan="2">&nbsp;&nbsp;<%=(String)vTemp.elementAt(j+4)%></td>
    <td width="32%"><%=(String)vTemp.elementAt(j+5)%></td>
    <td width="11%"><%=(String)vTemp.elementAt(j+7)%></td>
    <td width="12%"><%=(String)vTemp.elementAt(j+9)%></td>
    <td><%=(String)vTemp.elementAt(j+10)%></td>
  </tr>
  <%
	k = k +15;
	j = k;
	}//show the sub subject.

	j = j+15;
	i = j;
  }//show the main subject for same year/ semester.%>
  <tr>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td  colspan="3" align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
  <%}//show major / sub subject detail %>
  <!--    <tr>
      <td colspan="8" align="center"><strong>4th Year </strong></td>
    </tr>
    <tr>
      <td colspan="8" align="center"><strong><u>Twelve Full-Month Clinical Clerkship
        Program</u></strong></td>
    </tr>-->
  <tr>
    <td colspan="8" align="center">&nbsp;</td>
  </tr>
  <%
}//end of displyaing college of medicine course.
else if(strCourseType.compareTo("1") ==0)
{
	String strRequirement = "";//to display the requirement list.
	%>
</table>
      <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="3%" height="25" >&nbsp;</td>

      <td width="34%">COURSE REQUIREMENT</td>
          <td width="39%" >.................................................................</td>
          <td><div align="center">## units</div></td>
          <td>&nbsp;</td>
        </tr>
<%
fTotalUnits = 0;
for(i = 0 ; i< vTemp.size(); ++i){
if(strRequirement.compareTo((String)vTemp.elementAt(i+2)) == 0)
	continue;
%>
        <tr>
          <td height="25">&nbsp;</td>
          <td><%=(String)vTemp.elementAt(i+2)%></td>
          <td>.................................................................</td>
          <td><div align="center"><%=(String)vTemp.elementAt(i+3)%></div></td>
          <td>&nbsp;</td>
        </tr>
<%
i = i+7;
fTotalUnits += Float.parseFloat((String)vTemp.elementAt(i+3));
}%>
        <tr>
          <td height="25" >&nbsp;</td>
          <td >&nbsp;</td>
          <td >&nbsp;</td>
          <td width="10%" valign="top" align="center" ><hr size="1"><br><%=fTotalUnits%>
		  </td>
          <td width="14%" >&nbsp;</td>
        </tr>
      </table>

  <table width="100%" height="125" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7"><hr size="1"></td>
    </tr>
<%
for(i = 0 ; i< vTemp.size();){
strRequirement = (String)vTemp.elementAt(i+2);

%>    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"><strong><%=strRequirement%></strong></td>
      <td colspan="4">&nbsp;</td>
    </tr>
<%for(i = j; i< vTemp.size();){
if(strRequirement.compareTo( (String)vTemp.elementAt(j+2)) !=0)
	break;
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="23%"><%=(String)vTemp.elementAt(j)%></td>
      <td width="38%"><%=(String)vTemp.elementAt(j+1)%></td>
      <td width="9%"><%=(String)vTemp.elementAt(j+4)%></td>
	  <td width="9%"><%=(String)vTemp.elementAt(j+5)%></td>
	  <td width="9%"><%=(String)vTemp.elementAt(j+6)%></td>
    </tr>
<% 	j = j+10;
	i = j;
}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	  <td>&nbsp;</td><td>&nbsp;</td>
    </tr>
<%}//end of for loop to construct the course requriement.%>
  </table>
<%
			}//only if there course type is DOCTORAL / MASTERAL.
		}//if residency summery exisits
	   }//if student residency status in detail exists.


%>


<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#47768F">&nbsp;</td>
  </tr>

</table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
