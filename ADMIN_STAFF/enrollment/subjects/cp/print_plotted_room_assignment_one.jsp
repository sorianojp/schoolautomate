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
<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>
<%}

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
Vector vClassSize = new Vector();


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(WI.fillTextValue("room_i").length() > 0)  {
	vRetResult = SS.getRoomAssignmentDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
	else{
		if(WI.fillTextValue("show_class_size").length() > 0){
			strTemp = WI.fillTextValue("room_i");
			if (WI.fillTextValue("room_n").length() > 0) {
			  strTemp = "select room_index from e_room_detail where is_valid = 1 and room_number = '" + WI.fillTextValue("room_n") + "' ";
		
			  strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			}
			
			strTemp = 
				" select distinct  "+
				" (select sub_code from subject where SUB_INDEX = E_SUB_SECTION.SUB_INDEX),SECTION, classSize "+
				" from e_room_assign  "+
				" join e_room_detail on (e_room_detail.room_index = e_room_assign.room_index)  "+
				" join e_sub_section on (e_sub_section.sub_sec_index = e_room_assign.sub_sec_index)  "+
				" join( "+
				" 	select sub_sec_index as ssi, count(*) as classSize "+
				" 	from enrl_final_cur_list where is_valid = 1 and sy_from = "+WI.fillTextValue("school_year_fr")+
				" 	and is_valid = 1 and current_semester = "+WI.fillTextValue("offering_sem")+
				" 	and is_temp_stud =0 and is_confirmed = 1 and exists ( "+
				" 		select * from stud_curriculum_hist  "+
				" 		where enrl_final_cur_list.user_index = stud_curriculum_hist.user_index  "+
				" 		and stud_curriculum_hist.sy_from = enrl_final_cur_list.sy_from  "+
				" 		and is_valid = 1  "+
				" 		and semester = current_semester "+
				" 	) "+
				" 	group by sub_sec_index "+
				" )as enrl on (enrl.ssi = E_SUB_SECTION.SUB_SEC_INDEX) "+
				" where e_room_assign.is_valid = 1 and e_sub_section.offering_sy_from ="+WI.fillTextValue("school_year_fr")+
				" and offering_sem ="+WI.fillTextValue("offering_sem")	+
				" and e_room_assign.room_index = "+strTemp;
			
			java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				strTemp = rs.getString(1) + "<br>" +rs.getString(2);
				vClassSize.addElement(strTemp);
				vClassSize.addElement(rs.getString(3));
			}rs.close();
			
			
		}
	}
	
}

String[] astrConvertTerm = {"SUMMER","1ST","2ND","3RD"}; 

if(vRetResult != null && vRetResult.size() > 0) {
	Vector vTimeSch = new Vector();
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

	Vector vRoomSch = vRetResult;
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
	String strClassSize = null;
	dStartTime = 6.5d;
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
					<td>ROOM SCHEDULE</td>
				</tr>
			</table>
        </td>
	</tr>
  </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="76%" style="font-weight:bold">&nbsp;</td>
		<td width="24%" style="font-weight:bold">ROOM SCHEDULE</td>
	</tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td style="font-weight:bold" width="16%" class="thinborder" height="22">Description</td>
		<td width="24%" class="thinborder"><%=WI.getStrValue(vRetResult.remove(1), "&nbsp;")%></td>
		<td width="36%" rowspan="3" style="font-weight:bold; font-size:24px" class="thinborder" align="center">ROOM NUMBER </td>
		<td width="24%" rowspan="3" style="font-weight:bold; font-size:24px" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.remove(1))%></td>
	</tr>
	<tr>
	  <td style="font-weight:bold" class="thinborder" height="22">Area</td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.remove(0), "&nbsp;")%></td>
    </tr>
	<tr>
	  <td style="font-weight:bold" class="thinborder" height="22">SY-Term</td>
	  <td class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to").substring(2)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr style="font-weight:bold" align="center">
		<td width="16%" class="thinborder" height="24" align="center">TIME</td>
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
strClassSize = null;
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
/**			if(!SS.bolIsSchedExist(dStartTime, 1, vRoomSch)) {
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
			}
**/
		%>
		    <td height="15" <%if(false){%>rowspan="2"<%}%> class="thinborder" style="font-weight:bold"><%=vTimeSch.elementAt(p)%></td>
		<%}%>


<%////////////////Sunday.
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
		iIndexOf = vClassSize.indexOf(strValSU);
		if(iIndexOf > -1)
			strValSU += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		if(iRowSpanSU >0)
			strValSU = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValSU+"</font>";
		strRowSpanSU = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanSU   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>






<%//////////// monday.
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
		iIndexOf = vClassSize.indexOf(strValM);
		if(iIndexOf > -1)
			strValM += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		
		if(iRowSpanM >0)
			strValM = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValM+"</font>";
		strRowSpanM = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanM   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanM != null || iRowSpanM <=0){%>
	    <td height="15" class="thinborder"<%=WI.getStrValue(strRowSpanM)%>><%=WI.getStrValue(strValM, "&nbsp;")%></td>
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
		iIndexOf = vClassSize.indexOf(strValT);
		if(iIndexOf > -1)
			strValT += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		if(iRowSpanT >0)
			strValT = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValT+"</font>";
		strRowSpanT = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanT   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanT != null || iRowSpanT <=0){%>
	    <td height="15" class="thinborder"<%=WI.getStrValue(strRowSpanT)%>><%=WI.getStrValue(strValT, "&nbsp;")%></td>
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
		iIndexOf = vClassSize.indexOf(strValW);
		if(iIndexOf > -1)
			strValW += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		if(iRowSpanW >0)
			strValW = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValW+"</font>";
		strRowSpanW = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanW   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanW != null || iRowSpanW <=0){%>
	    <td height="15" class="thinborder"<%=WI.getStrValue(strRowSpanW)%>><%=WI.getStrValue(strValW, "&nbsp;")%></td>
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
		iIndexOf = vClassSize.indexOf(strValTH);
		if(iIndexOf > -1)
			strValTH += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		if(iRowSpanTH >0)
			strValTH = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValTH+"</font>";
		strRowSpanTH = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanTH   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanTH != null || iRowSpanTH <=0){%>
	    <td height="15" class="thinborder"<%=WI.getStrValue(strRowSpanTH)%>><%=WI.getStrValue(strValTH, "&nbsp;")%></td>
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
		iIndexOf = vClassSize.indexOf(strValF);
		if(iIndexOf > -1)
			strValF += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		if(iRowSpanF >0)
			strValF = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValF+"</font>";
		strRowSpanF = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanF   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanF != null || iRowSpanF <=0){%>
	    <td height="15" class="thinborder"<%=WI.getStrValue(strRowSpanF)%>><%=WI.getStrValue(strValF, "&nbsp;")%></td>
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
		iIndexOf = vClassSize.indexOf(strValS);
		if(iIndexOf > -1)
			strValS += WI.getStrValue((String)vClassSize.elementAt(iIndexOf+1),"(",")","");
		if(iRowSpanS >0)
			strValS = "<font style='color:red;font-weight:bold;font-size:14px;'>"+strValS+"</font>";
		strRowSpanS = " rowspan='"+String.valueOf(iRowSpan)+"'";
		iRowSpanS   = iRowSpan;
		
		bolIsUsed = true;
	}
}
%>

<%if(strRowSpanS != null || iRowSpanS <=0){%>
	    <td height="15" class="thinborder"<%=WI.getStrValue(strRowSpanS)%>><%=WI.getStrValue(strValS, "&nbsp;")%></td>
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
	    <td height="24" class="thinborder">&nbsp;</td>
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

<%
dbOP.cleanUP();
%>
