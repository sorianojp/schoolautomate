<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date, hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Untitled Document</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
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
	Vector vRetResult = null;
	int iSearchResult = 0;
	int i = 0;
	boolean bolPageBreak = false;

	vRetResult = restItems.getRestaurantItems(dbOP,request);
	if (vRetResult != null) {
	
		int iPage = 1; 
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(13*iMaxRecPerPage);	
	    if(vRetResult.size() % (iMaxRecPerPage*13) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>	 
<body onload="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  
  <tr>
    <td height="25" colspan="6" class="thinborder" align="center" ><b>:: LIST OF ITEMS  :: </b></td>
  </tr>
  <tr>
    <td width="10%" height="25" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>ITEM CODE </b></font></td>
    <td width="33%" class="thinborderBOTTOMLEFT" align="center"><b><font size="1">ITEM NAME </font></b></td>
    <td width="11%" height="25" class="thinborderBOTTOMLEFT" align="center"><b><font size="1">PURCHASE UNIT </font></b></td>
    <td width="11%" height="25" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>SELLING UNIT </b></font></td>
    <td width="12%" class="thinborderBOTTOMLEFT" align="center"><b><font size="1">QTY ON HAND<br />
(in Selling Unit ) </font></b></td>
    <td width="12%" class="thinborder" align="center"><font size="1"><b>SELLING PRICE </b></font></td>
    </tr>
	 <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=13,++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>	
  <tr>
    <td height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
    <td height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
		<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"0"); %>
		<td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+4);
			strTemp = CommonUtil.formatFloat(strTemp,true);
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
    <%
			if(WI.fillTextValue("with_record").equals("1"))
				strTemp = (String)vRetResult.elementAt(i+10);
			else
				strTemp = "";
		%>
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