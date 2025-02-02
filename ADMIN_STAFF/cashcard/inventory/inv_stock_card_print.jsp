<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, java.util.Calendar, 
																hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Item Stock Card</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script> 
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
//add security here.
try
	{
		dbOP = new DBOperation();
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//end of authenticaion code.
	RestItems restItems = new RestItems();
	Vector vItemInfo = null;
	Vector vRetResult = null;
	boolean bolHasBeginning = false;
	int iSearchResult = 0;
	String strEntryType = null;
	double dBalance = 0d;
	int i = 0;
	boolean bolPageBreak = false;
	
	Calendar calTemp = Calendar.getInstance();
	String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
	String strMonths = WI.fillTextValue("month_of");
 	String strYear = WI.fillTextValue("year_of");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));
	
	String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");
		
	vItemInfo = restItems.getRestItemInfo(dbOP,request);
		
	if(vItemInfo != null && vItemInfo.size() > 0)
		vRetResult = restItems.viewItemLedger(dbOP, request, (String)vItemInfo.elementAt(0));
%>
<body onload="javascript:window.print();">
<form name="form_">
  <%if(vItemInfo != null && vItemInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="1" cellspacing="1">
  <tr>
    <td width="14%" height="25"><b><strong>Item Name</strong></b></td>
		<%
			strTemp = (String)vItemInfo.elementAt(4);
		%>
    <td width="33%" height="25" class="thinborderBOTTOM"><b>:&nbsp;<%=strTemp%></b></td>
    <td width="15%" height="25"><strong>Purchase Unit </strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(6);
		%>
    <td width="38%" class="thinborderBOTTOM"><b>:&nbsp;<%=WI.getStrValue(strTemp)%></b></td>
  </tr>
  <tr>
    <td height="25"><strong>Item Code</strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(3);
		%>
    <td height="25" class="thinborderBOTTOM"><b>:&nbsp;<%=strTemp%></b></td>
    <td><strong>Selling Unit </strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(8);
		%>
    <td class="thinborderBOTTOM"><b>:&nbsp;<%=WI.getStrValue(strTemp)%></b></td>
  </tr>
  <tr>
    <td height="25"><b>Category </b></td>
		<%
			strTemp = (String)vItemInfo.elementAt(2);
		%>
    <td height="25" class="thinborderBOTTOM"><b>:&nbsp;<%=strTemp%></b></td>
    <td><strong>Conversion</strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(9);
		%>
    <td class="thinborderBOTTOM"><b>:&nbsp;<%=WI.getStrValue(strTemp)%></b></td>
  </tr>
  <tr>
    <td height="25"><strong>Selling Price</strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(10);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td class="thinborderBOTTOM"><b>:&nbsp;<%=strTemp%></b></td>
    <td><strong>Current Balance </strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(15);
		%>
    <td class="thinborderBOTTOM"><b>:&nbsp;<%=WI.getStrValue(strTemp)%></b></td>
  </tr>
  <tr>
    <td height="25"><b>Item Cost</b></td>
		<%
			strTemp = (String)vItemInfo.elementAt(14);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td class="thinborderBOTTOM"><b>:&nbsp;<%=strTemp%></b></td>
    <td><strong>Reorder Qty.</strong></td>
		<%
			strTemp = (String)vItemInfo.elementAt(13);
			if(WI.getStrValue(strTemp).equals("1"))			
				strTemp = (String)vItemInfo.elementAt(16);
			else
				strTemp = "n/a";
			
		%>
    <td class="thinborderBOTTOM"><b>:&nbsp;<%=strTemp%></b></td>
  </tr>
  <tr>
    <td height="10" colspan="4">&nbsp;</td>
  </tr>
</table>
	<%}%>
 <%	if (vRetResult != null) {
		int iIncr = 1;
		int iPage = 1; 
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(9*iMaxRecPerPage);	
	    if(vRetResult.size() % (iMaxRecPerPage*9) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
   <tr>
     <td align="right">Page <%=iPage%> of <%=iTotalPages%>&nbsp;</td>
   </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">  
  <tr>
    <td width="15%" height="25" align="center" class="thinborder"><font size="1"><b>DATE</b></font></td>
    <td width="40%" align="center" class="thinborder"><b><font size="1">PARTICULAR</font></b></td>
    <td width="15%" align="center" class="thinborder"><b><font size="1">STOCK IN </font></b></td>
    <td width="15%" align="center" class="thinborder"><b><font size="1">STOCK OUT </font></b></td>
    <td width="15%" align="center" class="thinborder"><b><font size="1">BALANCE  </font></b></td>
  </tr>
	<%
	for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iCount, iIncr++){
		i = iNumRec;
		strEntryType = (String)vRetResult.elementAt(i+5);
		if(!bolHasBeginning && strEntryType.equals("2"))
			bolHasBeginning = true;		

		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;
		
	%>	
  <tr>
    <td height="22" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+4);
		%>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
		<%
			if(!strEntryType.equals("0")){
				strTemp = (String)vRetResult.elementAt(i+1);
				if(bolHasBeginning)
					dBalance += Double.parseDouble(strTemp);
			}else
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			if(strEntryType.equals("0")){
				strTemp = (String)vRetResult.elementAt(i+1);
				if(bolHasBeginning)
					dBalance -= Double.parseDouble(strTemp);				
			}else
				strTemp = "&nbsp;";
		%>		
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			if(bolHasBeginning)
				strTemp = CommonUtil.formatFloat(dBalance, false);
			else
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
  </tr>
	<%}%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" ></DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
  </body>
</html>
<%
dbOP.cleanUP();
%>