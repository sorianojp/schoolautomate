<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ShowSubject()
{
	document.check_result.showSubject.value = "1";
}
function ShowResult()
{
	document.check_result.showResult.value = "1";
	document.check_result.e_period_time.value = document.check_result.exam_period[document.check_result.exam_period.selectedIndex].text;
}
function ReloadPage()
{
	document.check_result.submit();
}
</script>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,OLExam.OLETakeExam, java.util.Vector" %>
<%
 	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;String strTemp = null;
	Vector vSubList = new Vector();
	Vector vExamResult = new Vector();
	String[] astrConvertTestNo = {"I","True/False","II","Multiple choice","III","Matching type","IV","Objective","V","Essay"};
	String[] astrConvertAMPM = {"AM","PM"};
	int iQTypeIndex = 0;
	float fTotalPoints = 0; 
	float fTotalScore = 0;
	String strSubName = null;

	boolean bolShowSubject = false; // true if ShowSubject is called.
	boolean bolShowResult = false; // true if ShowResult is called. 
	boolean bolShowAllSub = false;
	if(request.getParameter("showSubject") != null && request.getParameter("showSubject").compareTo("1") ==0)
		bolShowSubject = true;
	if(request.getParameter("showResult") != null && request.getParameter("showResult").compareTo("1") ==0)
		bolShowResult = true;


//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		//exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

OLETakeExam oleTakeExam = new OLETakeExam();	
if(bolShowSubject)
{
	vSubList = oleTakeExam.getSubList(dbOP, request);
	if(vSubList == null || vSubList.size() ==0)
		strErrMsg = oleTakeExam.getErrMsg();
	else if(bolShowResult)
	{
		vExamResult = oleTakeExam.showResultPerSub(dbOP, request.getParameter("stud_id"), request.getParameter("exam_period"),request.getParameter("subject"));		
		if(vExamResult == null || vExamResult.size() ==0)
			strErrMsg = oleTakeExam.getErrMsg();
	}
}
	
if(strErrMsg == null) strErrMsg = "";

%>
<form action="./online_exam_check_result_page1.jsp" method="post" name="check_result">
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5" ><div align="center"><strong><font color="#FFFFFF">:: 
          ONLINE EXAMINATION - CHECK RESULT ::</font></strong></div></td>
    </tr>
    
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="4"><%=strErrMsg%></td>
    </tr>
	<tr> 
      <td width="2%"></td>
      <td width="18%"></td>
      <td colspan="3"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Student ID</td>
      <td width="23%"><input name="stud_id" type="hidden" size="20" 
	  value="<%=(String)request.getSession(false).getAttribute("userId")%>"> <font size="2"><b><%=(String)request.getSession(false).getAttribute("userId")%></b></font> 
      </td>
      <td colspan="2"></a> Year &nbsp;
<select name="year_level" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Term</td>
      <td><select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="5%">&nbsp;</td>
      <td width="52%"> 
        <input name="image2" type="image" src="../../images/form_proceed.gif" onClick="ShowSubject();"></td>
    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
</table>
<%
if(vSubList != null && vSubList.size()> 0)
{%>  <table width="100%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">

    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="18%">Examination Period </td>
      <td width="80%" colspan="3"><select name="exam_period" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Subject Code</td>
      <td colspan="3"><select name="subject" onChange="ReloadPage();">
          <option value="0">select any</option>
          <%
strTemp =WI.fillTextValue("subject");

for(int i = 0; i< vSubList.size(); ++i)
{
	if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
          <%}
}%>
        </select> 
        <%
//get the subject name here. 
strSubName = dbOP.mapOneToOther("subject","sub_index",request.getParameter("subject"),"sub_name",null);
if(strSubName == null)
	strSubName = "";
%>
        Subject Title : <strong><%=strSubName%></strong> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><input name="image" type="image" src="../../images/form_proceed.gif" onClick="ShowResult();"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(vExamResult != null && vExamResult.size() > 0){%>
  <table width="100%" border="1" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#BECED3"> 
      <td height="29" colspan="5"><div align="center">EXAMINATION RESULTS FOR 
          SUBJECT <strong><%=strSubName%> </strong>FOR <strong><%=WI.fillTextValue("e_period_time")%></strong> 
          EXAMINATION</div></td>
    </tr>
    <tr> 
      <td  colspan="2" height="25">&nbsp;</td>
      <td  colspan="3" height="25"><font size="1"><a href="online_exam_check_result_print_per_subject.htm" target="_blank"><img src="../../images/print.gif" width="58" height="26" border="0"></a>click 
        to print this result </font></td>
    </tr>
<%
//print different batch for different exams - stud-ref index.
String strStudRefIndex = null;
for(int i = 0; i< vExamResult.size(); ++i)
{
strStudRefIndex = (String)vExamResult.elementAt(i+11);
%>
	 <tr> 
      <td  colspan="2" height="25">Date and time of exam : <strong><%=(String)vExamResult.elementAt(i+6)%> 
        -<%=(String)vExamResult.elementAt(i+7)%>:<%=CommonUtil.formatMinute((String)vExamResult.elementAt(i+8))%> 
        <%=astrConvertAMPM[Integer.parseInt((String)vExamResult.elementAt(i+9))]%></strong></td>
      <td  colspan="3" height="25" align="right"><font size="1"><a href="./view_result_detail.jsp?stud_ref=<%=strStudRefIndex%>"><img src="../../images/view.gif" border="0"></a><font size="1">click 
        to view result details</font></font></td>
    </tr>
    <tr> 
      <td width="18%" height="25"><div align="center">TEST #</div></td>
      <td width="28%"><div align="center">TEST TYPE</div></td>
      <td width="24%"><div align="center">TOTAL POINTS</div></td>
      <td height="25" colspan="2"><div align="center">YOUR SCORE</div></td>
    </tr>
 <%
 for(int j =i; j< vExamResult.size(); ++j){
 //if stud reference index is different - print a different batch. 
 if(strStudRefIndex.compareTo((String)vExamResult.elementAt(j+11)) != 0)
 	break;
 
 //System.out.println(" I am printing here value of I : "+i);
 //System.out.println(vExamResult.size());
 iQTypeIndex =Integer.parseInt( (String)vExamResult.elementAt(j)); 
 fTotalPoints += Float.parseFloat((String)vExamResult.elementAt(j+2)); 
 fTotalScore += Float.parseFloat((String)vExamResult.elementAt(j+5)); 
 %>
    <tr> 
      <td height="25"><div align="center"><%=astrConvertTestNo[(iQTypeIndex-1)*2]%></div></td>
      <td align="center"><%=astrConvertTestNo[(iQTypeIndex-1)*2 + 1]%></td>
      <td align="center"><%=(String)vExamResult.elementAt(j+2)%></td>
      <td align="center"><%=(String)vExamResult.elementAt(j+5)%></td>
    </tr>
<%
j = j+11;
i = j; 
 }
%>
    <tr> 
      <td  colspan="2"height="25">TOTAL SCORE : <strong><%=fTotalScore%></strong></td>
      <td  colspan="2" height="25">PERCENTAGE : <strong><%=CommonUtil.calculatePercentage(fTotalPoints,fTotalScore)%></strong></td>
    </tr>
<%
fTotalPoints = 0; fTotalScore = 0;
}//end of displayin result if there are more than one exam for same subject.//for(int i = 0; i< vExamResult.size(); ++i)
%>
  </table>
<!--  <table width="100%" border="1" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#BECED3"> 
      <td height="25" colspan="4"><div align="center">EXAMINATION RESULTS FOR 
          <strong>ALL SUBJECTS</strong> FOR <strong>$exam_period</strong> EXAMINATION</div></td>
    </tr>
    <tr> 
      <td  colspan="4" height="25"><a href="online_exam_check_result_print_all.htm" target="_blank"><img src="../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
        to print these results </font></td>
    </tr>
    <tr> 
      <td  colspan="2" height="25">Subject :<strong> $subject_code / $subj_desc</strong></td>
      <td  colspan="2" height="25">Date and time of exam : <strong>$date / $time</strong></td>
    </tr>
    <tr> 
      <td width="18%" height="25"><div align="center"><strong><font size="1">TEST 
          #</font></strong></div></td>
      <td width="28%"><div align="center"><strong><font size="1">TEST TYPE</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">TOTAL POINTS</font></strong></div></td>
      <td width="30%" height="25"><div align="center"><strong><font size="1">YOUR 
          SCORE</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25"><div align="center">I</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">II</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">III</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">IV</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">V</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td  colspan="2"height="25">TOTAL SCORE : <strong>$total_score</strong></td>
      <td  colspan="2" height="25">PERCENTAGE : <strong>$percentage</strong></td>
    </tr>
    <tr> 
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td  colspan="4" height="25">Subject :<strong><strong> $subject_code / $subj_desc</strong></strong></td>
    </tr>
    <tr> 
      <td width="18%" height="25"><div align="center"><strong><font size="1">TEST 
          #</font></strong></div></td>
      <td width="28%"><div align="center"><strong><font size="1">TEST TYPE</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">TOTAL POINTS</font></strong></div></td>
      <td width="30%" height="25"><div align="center"><strong><font size="1">YOUR 
          SCORE</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25"><div align="center">I</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">II</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">III</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">IV</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">V</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td  colspan="2"height="25">TOTAL SCORE : <strong>$total_score</strong></td>
      <td  colspan="2" height="25">PERCENTAGE : <strong>$percentage</strong></td>
    </tr>
    <tr> 
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td  colspan="4" height="25">Subject :<strong> $subject_code / $subj_desc</strong></td>
    </tr>
    <tr> 
      <td width="18%" height="25"><div align="center"><strong><font size="1">TEST 
          #</font></strong></div></td>
      <td width="28%"><div align="center"><strong><font size="1">TEST TYPE</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">TOTAL POINTS</font></strong></div></td>
      <td width="30%" height="25"><div align="center"><strong><font size="1">YOUR 
          SCORE</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25"><div align="center">I</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">II</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">III</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">IV</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center">V</div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td  colspan="2"height="25">TOTAL SCORE : <strong>$total_score</strong></td>
      <td  colspan="2" height="25">PERCENTAGE : <strong>$percentage</strong></td>
    </tr>
  </table>-->
  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>

    <tr> 
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<%	}//vSubList is having subject list. 
}
%>
<input type="hidden" name="showResult" value="0">
<input type="hidden" name="showSubject" value="<%=WI.fillTextValue("showSubject")%>">
<input type="hidden" name="e_period_time">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>