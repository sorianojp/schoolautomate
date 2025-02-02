<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	
	boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
	if(!bolIsFinal){%>
		<jsp:forward page="./grade_releasing_print_swu_midterm.jsp"></jsp:forward>
	<%return;}
	
	String strTemp = null;
	DBOperation dbOP = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print","grade_releasing_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
String strCurHistIndex = null;
//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));


Vector vGradeDetail = null;
//Vector vAdditionalInfo = null;
//Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;




if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{

	//get grade sheet release information.
	
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,true,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();
		
	strTemp = "select cur_hist_index from stud_curriculum_hist where is_valid =1 and sy_from = "+request.getParameter("sy_from")+
		" and semester = "+request.getParameter("semester")+
		" and user_index = "+(String)vStudInfo.elementAt(0);
	strCurHistIndex = dbOP.getResultOfAQuery(strTemp,0);
}




if(strErrMsg == null) strErrMsg = "";


/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}
String[] astrConvertSem = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER", "FOURTH SEMESTER"};
String strMailAddress = null;

if(WI.fillTextValue("print_report_card").length() > 0){
	strTemp = "select RES_HOUSE_NO, RES_CITY, RES_PROVIENCE, RES_COUNTRY, RES_ZIP from INFO_CONTACT where USER_INDEX = "+(String)vStudInfo.elementAt(0);	
	strMailAddress = null;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next())
		strMailAddress = WI.getStrValue(rs.getString(1)) + "<br>"+WI.getStrValue(rs.getString(5))+
			WI.getStrValue(rs.getString(2), ", ", "", "")+WI.getStrValue(rs.getString(3),", ","","");
	rs.close();
}


%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

@media print { 
	  @page {
			margin-bottom:.1in;
			margin-top:0in;
			margin-left:.5in;
			margin-right:.5in;
		}
	}
body {
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
}


td {
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: Dot-Matrix ;
	font-size: 11px;
}

th {
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;

	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborder {

    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;

	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }

    TD.thinborderTopRightBottom {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }
	
	TD.thinborderTopBottom {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }

</style>

</head>

<body <%if(WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>
<%if(WI.getStrValue(strErrMsg).length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){
//i will increment the print count here.	
//I use g_sheet_final bec. this format is for finals only		
if(strCurHistIndex != null && strCurHistIndex.length() >0){
	
	strTemp = "update g_sheet_final set SWU_PRINT_COUNT = isnull(SWU_PRINT_COUNT,0) + 1 "+
		",SWU_PRINT_BY="+(String)request.getSession(false).getAttribute("userIndex")+
		",SWU_PRINT_DATE='"+WI.getTodaysDate()+"' where is_valid =1 and cur_hist_index = "+strCurHistIndex+
		" and GRADE_NAME like '"+WI.fillTextValue("grade_name")+"%'";
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr>
		<td width="12%">&nbsp;</td>
		<td width="20%"><%=WI.fillTextValue("stud_id")%></td>		
		<td width="46%"><%=(String)vStudInfo.elementAt(1)%></td>	  
	  	<td width="22%"><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3)," MAJOR IN ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vStudInfo.elementAt(4)," - ","","")%>		</td>
	</tr>
</table>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	
	<tr>
		<td valign="top" height="150">
			<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td rowspan="2">&nbsp;</td>
				<td width="55%" height="25" align="center" valign="bottom">&nbsp;</td>
				<Td colspan="3" rowspan="2">&nbsp;</Td>
				<Td rowspan="2" width="10%">&nbsp;</Td>
			</tr>
			<tr>
			<%
			if(Integer.parseInt(WI.fillTextValue("semester")) == 0)
				strTemp = WI.fillTextValue("sy_to");
			else
				strTemp = WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
			%>
			    <td align="center" valign="bottom">
				<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> &nbsp; &nbsp; &nbsp; 
				<%=strTemp%>				</td>
			</tr>
			
  <%
   int iSubjCount = 0;
   int iRowSize = 8;
   int k = 0;

String strGradeValue = null;
String strSubCode    = null; //System.out.println(vGradeDetail);
for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
	++iSubjCount;
	strSubCode = (String)vGradeDetail.elementAt(i + 1);
	
	if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
		bolPutParanthesis = true;
		try {
			double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));			
			bolPutParanthesis = true; 
			if(dGrade < 5d)
				vGradeDetail.setElementAt("(3.0)",i + 3);
			else 
				vGradeDetail.setElementAt("(0.0)",i + 3);			
		}
		catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
	}
	else	
		bolPutParanthesis = false;	



if(vGradeDetail.elementAt(i) == null) {	
	strTemp = " colspan=3";
}else
	strTemp = "";
//added to show grade not verified instead of grade and remark.
//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {	
		strTemp = " colspan=3";
	vGradeDetail.setElementAt(null,i);
	vGradeDetail.setElementAt("Grade not verified", i + 5);
	//vGradeDetail.setElementAt("&nbsp;", i + 5);	
}


strGradeValue = (String)vGradeDetail.elementAt(i+5);
%>
  <tr>
		<td width="15%"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
		<td><%=((String)vGradeDetail.elementAt(i+2)).toUpperCase()%></td>
		<td width="7%" <%=strTemp%> align="center"><%=strGradeValue%></td>	
<%
if(strTemp.length() == 0){
strErrMsg = (String)vGradeDetail.elementAt(i + 5);
strTemp = null;
if(vGradeDetail.size() > (i + 5 + 8) && strErrMsg != null && 
		( (strErrMsg.toLowerCase().indexOf("inc") == -1 || strErrMsg.toLowerCase().indexOf("inr") == -1 || strErrMsg.toLowerCase().indexOf("ine") == -1) ) &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
		strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);		
      	strErrMsg = (String)vGradeDetail.elementAt(i + 5 + 8);
		i += 8;
}else strErrMsg = "";
%>
		<td width="7%" align="center"><%=strErrMsg%></td>
<%
if(strTemp == null)
	strTemp = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0");
%>
        <td width="6%" align="right">&nbsp; <%=WI.getStrValue(strTemp)%></td>
<%}%>
		<td>&nbsp;</td>		



  </tr>
	  
<%} // end for loop%>
	
	<tr><td height="20" colspan="7" align="center"> 
	-swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu-  </td></tr>
</table>
		</td>
	</tr>
</table>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td valign="top" width="19%"><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1).toUpperCase()%><br>
		<%=WI.getTodaysDateTime()%></td>	  	
	    <td width="81%" valign="top"><%=WI.getStrValue(strMailAddress)%></td>
	</tr>	
</table>



<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();
%>
</body>
</html>
