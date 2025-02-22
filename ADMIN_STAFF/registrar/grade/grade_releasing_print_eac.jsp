<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

	boolean bolIsBatch = WI.fillTextValue("batch_print").equals("1");

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp2 = null;
	String strTemp3 = null;
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

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;
String strPmtSchIndex = null;

if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get grade sheet release information.

	boolean bolIncludeEnrolledSubject = true;

	strPmtSchIndex = "select pmt_sch_index from fa_pmt_schedule where exam_name = '"+request.getParameter("grade_for")+"'";
	strPmtSchIndex = dbOP.getResultOfAQuery(strPmtSchIndex, 0);


	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,bolIncludeEnrolledSubject,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	//vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

//	System.out.println(vAdditionalInfo);
	//System.out.println(vGradeDetail);

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}

//dbOP.executeUpdateWithTrans("alter table subject add tot_acad_unit float", null, null, false);

String strSQLQuery = "update subject set tot_acad_unit = "+
					"(select max(lec_unit+lab_unit) from curriculum where subject.sub_index =curriculum.sub_index and is_valid = 1) "+
					"where is_del <> 1 and tot_acad_unit is null";
if(!bolIsBatch)
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
strSQLQuery = "update subject set tot_acad_unit = "+
					"(select max(unit) from cculum_masters where subject.sub_index = cculum_masters.sub_index and is_valid = 1) "+
					"where tot_acad_unit is null and is_del <> 1";
if(!bolIsBatch)
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
strSQLQuery = "update subject set tot_acad_unit ="+
					"(select max(main_unit) from cculum_medicine where subject.sub_index =cculum_medicine.main_sub_index and is_valid = 1) "+
					"where tot_acad_unit is null and is_del <> 1";
if(!bolIsBatch)
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

strSQLQuery = "select tot_acad_unit from subject where sub_code = ? and sub_name = ? and is_del <> 1";
java.sql.PreparedStatement pstmtGetSubUnit = dbOP.getPreparedStatement(strSQLQuery);

if(strSchCode == null)
	strSchCode = "";
//strSchCode = "AUF";

double dTotalUnits = 0d;


boolean bolIsCollegeOnly = true;
boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");


String[] astrConvertSem = {"Summer","1st","2nd","3rd"};


String strGradeValue = null;
String strCE = null;
double dUnitEarned = 0d;
double dExcludedUnit = 0d;
double dUWGrade = 0d;// if UW is the remark Grade will be 5 and units will be 2.5
double dOrgUWGrade = 0d;
double dExemptedUnit = 0d;// do not compute if OW or INC
double dTotSubUnit = 0d;
double dTotSubUnitComputed = 0d;
double dSubjectUnit = 0d;
java.sql.ResultSet rs = null;
double dGWA = 0d;

if(vGradeDetail != null && vGradeDetail.size() > 0) {
	dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"), (String)vStudInfo.elementAt(6),
			(String)vStudInfo.elementAt(7),null);
}

boolean bolIsCavite = false;
strSQLQuery = dbOP.getResultOfAQuery("select info5 from sys_info", 0);
if(strSQLQuery != null && strSQLQuery.equals("Cavite"))
	bolIsCavite = true;
/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}
//System.out.println(strErrMsg);

String strHoldingMsg = null;
if(vStudInfo != null && vStudInfo.size() > 0) {
		strHoldingMsg = new utility.MessageSystem().getSystemMsg(dbOP, (String)vStudInfo.elementAt(0), 4);
		if(WI.fillTextValue("allow_with_balance").length() > 0)
			strHoldingMsg = "";
		if(strHoldingMsg == null) {
			//check o/s balance.. strPmtSchIndex

			//check if PN given.
			strTemp = "select user_index from FA_STUD_PROMISORY_NOTE where is_valid = 1 and sy_from = "+
			WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+" and user_index = "+(String)vStudInfo.elementAt(0)+
			" and is_temp_stud_ = 0 and pmt_sch_index = "+strPmtSchIndex;
			strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			if(strTemp == null) {
				double dOutStandingBal = new enrollment.FAFeeOperation().calOutStandingOfPrevYearSem(dbOP,(String)vStudInfo.elementAt(0), true, true);
				if(dOutStandingBal > 0.5d)
					strHoldingMsg = "WITH BALANCE";
				/**
				enrollment.FAAssessment FA = new enrollment.FAAssessment();
				Vector vInstallmentDtls = FA.getInstallmentSchedulePerStudPerExamSch(dbOP,strPmtSchIndex, (String)vStudInfo.elementAt(0),
										WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),(String)vStudInfo.elementAt(4), WI.fillTextValue("semester")) ;
				if(vInstallmentDtls == null)
					strErrMsg = FA.getErrMsg();
				else {
					double dDueForThisPeriod = Double.parseDouble((String)vInstallmentDtls.elementAt(5));
					//System.out.println(dDueForThisPeriod+" ID NUMBER: "+request.getParameter("stud_id"));
					if(dDueForThisPeriod > 1d)
						strHoldingMsg = "WITH BALANCE";
				}**/
			}////by pass if there is pN.

		}
}

if(WI.fillTextValue("allow_with_balance").length() > 0)
	strHoldingMsg = null;


Vector vExcludeGWA = new Vector();
strSQLQuery = "select sub_code from subject join GWA_EXCLUDED on (GWA_EXCLUDED.sub_index = subject.sub_index) ";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) 
	vExcludeGWA.addElement(rs.getString(1));
rs.close();	

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


-->
</style>

</head>

<body topmargin="1" bottommargin="0" <%if(!strSchCode.startsWith("DBTC") && WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>
<%if(strErrMsg != null) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){%>
<br>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td width="78%" height="20"><div align="center">
          <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
         </div></td>
      <td width="22%" height="20">Date: <%=WI.getTodaysDate(1)%></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr>
    <td width="5%" height="19" >&nbsp;</td>
    <td width="73%" ><%=request.getParameter("stud_id")%></td>
    <td ><%=WI.getStrValue(vStudInfo.elementAt(4))%></td>
  </tr>
  <tr>
    <td height="18" >&nbsp;</td>
    <td height="18" ><%=(String)vStudInfo.elementAt(1)%></td>
    <td width="22%" height="18" >
		<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(15));
		else
			strTemp = "";
	%><%=strTemp%>
	</td>
  </tr>
  <tr>
    <td height="20" >&nbsp;</td>
    <td height="20" colspan="2" ><%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></td>
  </tr>
</table>
<br>
<table  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" height="350px">
	<tr>
		<td valign="top">
			<%if(strHoldingMsg == null) {%>
			<table  width="100%" border="0" cellspacing="0" cellpadding="0">
			  <tr>
				<td width="3%" align="center" class="thinborder">&nbsp;<!--<font size="1"><strong>Control Number </strong></font>--></td>
				<td width="15%" height="20" align="center" class="thinborder">&nbsp;<!--Subject Code--></td>
				<td width="30%" align="center" class="thinborder">&nbsp;<!--Subject Name--></td>
				<td width="6%" align="center" class="thinborder">&nbsp;<!--<strong><font size="1">Credit</font></strong>--></td>
				<td width="6%" align="center" class="thinborder">&nbsp;<!--Grade--></td>
			    <td width="6%" align="center" class="thinborder">&nbsp;</td>
			  </tr>
			  <%
			  int iRowSize = 8;

			  for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
				//reset if not verified..
				if(false && vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {
					vGradeDetail.setElementAt(null,i);
					vGradeDetail.setElementAt("Grade not verified", i + 5);
					vGradeDetail.setElementAt("0.0", i + 3);
				}
				//end.

				if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf((String)vGradeDetail.elementAt(i + 1)) != -1) {//sub code.
					bolPutParanthesis = true;
					try {
						double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));
						//System.out.println(dGrade);
						bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
						if(dGrade < 5d) {
							vGradeDetail.setElementAt("(3.0)",i + 3);
							dUnitEarned += 3d;
							//dTotSubUnit += dGrade * 3d;
						}
						else
							vGradeDetail.setElementAt("(0.0)",i + 3);

					}
					catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
				}
				else
					bolPutParanthesis = false;

			  	strGradeValue = (String)vGradeDetail.elementAt(i+5);
				if(strGradeValue != null && strGradeValue.startsWith("Grade")) {
					strGradeValue = "&nbsp;";
				}
				strCE = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0.0");
				try {
					double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));
					double dCE = Double.parseDouble(strCE);

					if(dGrade > 0d && dCE > 0d) {
						dUnitEarned += dCE;
						//dTotSubUnit += dGrade * dCE;
					}
				}
				catch(Exception e) {}
				//added for Special case for EAC.
				try {
					Double.parseDouble((String)vGradeDetail.elementAt(i + 5));
				}
				catch(Exception e) {
					//if(vExcludeGWA.indexOf((String)vGradeDetail.elementAt(i + 1)) == -1)
					//	dGWA = 0d;
				}
				


				strTemp = (String)vGradeDetail.elementAt(i+2);
				if(strTemp != null && strTemp.length() > 50)
					strTemp = strTemp.substring(0, 50);

				pstmtGetSubUnit.setString(1, (String)vGradeDetail.elementAt(i + 1));
				pstmtGetSubUnit.setString(2, (String)vGradeDetail.elementAt(i + 2));
				rs = pstmtGetSubUnit.executeQuery();
				if(rs.next()) {
					dSubjectUnit=  rs.getDouble(1);
					dTotSubUnit += dSubjectUnit;
				}
				else
					dSubjectUnit = 0d;
				rs.close();
				
				
				
				if(strGradeValue != null && (strGradeValue.toLowerCase().equals("inc") ||  strGradeValue.toLowerCase().equals("ow") 
							|| strGradeValue.toLowerCase().equals("uw") || strGradeValue.toLowerCase().startsWith("&nbsp")  )   ){				
					if(strGradeValue.toLowerCase().equals("uw")) {
						dUWGrade += (5 * 2.5);	
						dOrgUWGrade	+= (5 * dSubjectUnit);								
						dTotSubUnitComputed += 2.5;
					}else{
						try{						
							dExemptedUnit += dSubjectUnit;
							dTotSubUnitComputed += dSubjectUnit;
							if(vExcludeGWA.indexOf((String)vGradeDetail.elementAt(i + 1)) > -1)
								dExcludedUnit += dSubjectUnit;
						}catch(Exception e){}
					}
				}else if(vExcludeGWA.indexOf((String)vGradeDetail.elementAt(i + 1)) > -1){
					try{						
						dExemptedUnit += dSubjectUnit;
						dTotSubUnitComputed += dSubjectUnit;
						dExcludedUnit += dSubjectUnit;
					}catch(Exception e){}
				}else
					dTotSubUnitComputed += dSubjectUnit;
					
					
			  %>
				  <tr>
					<td class="thinborder" height="20"></td>
					<td class="thinborder"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
					<td class="thinborder"><%=strTemp%></td>
					<td class="thinborder"><%=dSubjectUnit%></td>
					<td class="thinborder"><%=CommonUtil.formatFloat(strGradeValue,true)%></td>
				    <td class="thinborder"><%=strCE%></td>
				  </tr>
			  <%}

			  /*strTemp = "0.0";
			  if(dUnitEarned > 0d) {
			  	strTemp = Double.toString(dTotSubUnit/dUnitEarned)+"00000";
				int iIndexOf = strTemp.indexOf(".");
				strTemp = strTemp.substring(0,iIndexOf + 3);
			  }*/
			  %>
			  	 <tr>
			  	     <td class="thinborder" height="20"></td>
			  	     <td class="thinborder">&nbsp;</td>
			  	     <td class="thinborder">&nbsp;</td>
			  	     <td class="thinborder"><div style="border-top:solid 1px #000000; width:70%;"><%=CommonUtil.formatFloat(dTotSubUnit,1)%></div></td>
	  	             <td class="thinborder">&nbsp;</td>
	  	             <td class="thinborder"><div style="border-top:solid 1px #000000; width:70%;"><%=CommonUtil.formatFloat(dUnitEarned,1)%></div></td>
		  	    </tr>
				<%if(dGWA > 0d) {
				//I have to put back the computed grade sum((lec_unit + lab_unit)*isnull(grade,0)) to its original.
				Vector vTemp = new Vector();
				
				vTemp.addElement(Double.toString(dGWA));
				vTemp.addElement(Double.toString(dTotSubUnit));
				vTemp.addElement(Double.toString(dExcludedUnit));
				
				dGWA = dGWA * (dTotSubUnit - dExcludedUnit);
				
				vTemp.addElement(Double.toString(dGWA));
				vTemp.addElement(Double.toString(dUWGrade));
				vTemp.addElement(Double.toString(dOrgUWGrade));
				vTemp.addElement(Double.toString(dTotSubUnitComputed));
				vTemp.addElement(Double.toString(dExemptedUnit));
				
				//then make the computation again here.
				dGWA = ((dGWA + dUWGrade) - dOrgUWGrade) / (dTotSubUnitComputed - dExemptedUnit);				
				%>
			  	 <tr>
				    <td class="thinborder" height="20"></td>
				    <td class="thinborder">&nbsp;</td>
				    <td class="thinborder">&nbsp;</td>
				    <td colspan="3" class="thinborder">Average Grade: <%=CommonUtil.formatFloat(dGWA, 2)%></td>
		         </tr>
			  <%}%>
			</table>
			<%}else{%>
			<br><br><br><br>
				<p style="font-size:12px;" align="center"><%=strHoldingMsg%></p>

			<%}%>

		</td>
	</tr>
</table>

<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="50%">NOTE: <br>
			INC grades must be completed within
			  <%if(bolIsCavite){%> ONE SEMESTER only.<%}else{%> a year, <br>otherwise they become failure.<%}%>		</td>
		<td width="43%" align="center"><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></td>
	  <td width="7%" align="center">&nbsp;</td>
	</tr>
</table>

<%}//end if student info is not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>
